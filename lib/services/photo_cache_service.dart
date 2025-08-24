import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:youphotomobile/api/image.dart';
import 'package:youphotomobile/api/album.dart';
import 'package:youphotomobile/config.dart';

class PhotoCacheService {
  static final PhotoCacheService _instance = PhotoCacheService._internal();
  static Database? _database;

  factory PhotoCacheService() {
    return _instance;
  }

  PhotoCacheService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'photo_cache2.db');
    return await openDatabase(
      path,
      version: 1, // Increment version for migration
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> _createDb(Database db, int version) async {
    // Create albums table first since photo_cache references it
    await db.execute('''
      CREATE TABLE albums(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER,
        name TEXT,
        session TEXT,
        cover INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE photo_cache(
        id INTEGER PRIMARY KEY,
        photo_id INTEGER,
        album_id INTEGER,
        name TEXT,
        thumbnail TEXT,
        created_at TEXT,
        updated_at TEXT,
        width INTEGER,
        height INTEGER,
        md5 TEXT,
        blur_hash TEXT,
        lat REAL,
        lng REAL,
        address TEXT,
        country TEXT,
        administrative_area1 TEXT,
        administrative_area2 TEXT,
        locality TEXT,
        route TEXT,
        street_number TEXT,
        premise TEXT,
        last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (album_id) REFERENCES albums(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE photo_tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        photo_id INTEGER,
        tag TEXT,
        source TEXT,
        rank REAL,
        FOREIGN KEY (photo_id) REFERENCES photo_cache(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE photo_colors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        photo_id INTEGER,
        value TEXT,
        percent REAL,
        rank INTEGER,
        cnt INTEGER,
        FOREIGN KEY (photo_id) REFERENCES photo_cache(id)
      )
    ''');
  }

  Future<void> cachePhoto(Photo photo, int albumId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Insert photo data
      final photoId = await txn.insert('photo_cache', {
        'photo_id': photo.id,
        'album_id': albumId,
        'name': photo.name,
        'thumbnail': photo.thumbnail,
        'created_at': photo.createdAt,
        'updated_at': photo.updatedAt,
        'width': photo.width,
        'height': photo.height,
        'md5': photo.md5,
        'blur_hash': photo.blurHash,
        'lat': photo.lat,
        'lng': photo.lng,
        'address': photo.address,
        'country': photo.country,
        'administrative_area1': photo.administrativeArea1,
        'administrative_area2': photo.administrativeArea2,
        'locality': photo.locality,
        'route': photo.route,
        'street_number': photo.streetNumber,
        'premise': photo.premise,
      });

      // Insert tags
      for (var tag in photo.tag) {
        await txn.insert('photo_tags', {
          'photo_id': photoId,
          'tag': tag.tag,
          'source': tag.source,
          'rank': tag.rank,
        });
      }

      // Insert colors
      for (var color in photo.imageColors) {
        await txn.insert('photo_colors', {
          'photo_id': photoId,
          'value': color.value,
          'percent': color.percent,
          'rank': color.rank,
          'cnt': color.cnt,
        });
      }
    });
  }

  Future<Photo?> getCachedPhoto(int photoId, int albumId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'photo_cache',
      where: 'photo_id = ? AND album_id = ?',
      whereArgs: [photoId, albumId],
    );

    if (maps.isEmpty) return null;

    final photoMap = maps.first;

    // Get tags
    final List<Map<String, dynamic>> tagMaps = await db.query(
      'photo_tags',
      where: 'photo_id = ?',
      whereArgs: [photoMap['id']],
    );

    // Get colors
    final List<Map<String, dynamic>> colorMaps = await db.query(
      'photo_colors',
      where: 'photo_id = ?',
      whereArgs: [photoMap['id']],
    );

    final photo = Photo.fromJson({
      'id': photoMap['photo_id'],
      'name': photoMap['name'],
      'thumbnail': photoMap['thumbnail'],
      'createdAt': photoMap['created_at'],
      'updatedAt': photoMap['updated_at'],
      'width': photoMap['width'],
      'height': photoMap['height'],
      'md5': photoMap['md5'],
      'blurHash': photoMap['blur_hash'],
      'lat': photoMap['lat'],
      'lng': photoMap['lng'],
      'address': photoMap['address'],
      'country': photoMap['country'],
      'administrativeArea1': photoMap['administrative_area1'],
      'administrativeArea2': photoMap['administrative_area2'],
      'locality': photoMap['locality'],
      'route': photoMap['route'],
      'streetNumber': photoMap['street_number'],
      'premise': photoMap['premise'],
      'tag': tagMaps
          .map((tag) => {
                'tag': tag['tag'],
                'source': tag['source'],
                'rank': tag['rank'],
              })
          .toList(),
      'imageColors': colorMaps
          .map((color) => {
                'value': color['value'],
                'percent': color['percent'],
                'rank': color['rank'],
                'cnt': color['cnt'],
              })
          .toList(),
    });

    return photo;
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('photo_tags');
      await txn.delete('photo_colors');
      await txn.delete('photo_cache');
    });
  }

  Future<void> clearAlbumCache(int albumId) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> photos = await txn.query(
        'photo_cache',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );

      for (var photo in photos) {
        await txn.delete(
          'photo_tags',
          where: 'photo_id = ?',
          whereArgs: [photo['id']],
        );
        await txn.delete(
          'photo_colors',
          where: 'photo_id = ?',
          whereArgs: [photo['id']],
        );
      }

      await txn.delete(
        'photo_cache',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );
    });
  }

  // Add album-related methods
  Future<void> insertAlbum(
      int albumId, String? name, String session, int? cover) async {
    final db = await database;

    // Check if record exists with same album_id and session
    final List<Map<String, dynamic>> existing = await db.query(
      'albums',
      where: 'album_id = ? AND session = ?',
      whereArgs: [albumId, session],
    );

    if (existing.isNotEmpty) {
      // Update existing record
      await db.update(
        'albums',
        {
          'name': name ?? 'Unknown',
          'cover': cover,
        },
        where: 'album_id = ? AND session = ?',
        whereArgs: [albumId, session],
      );
    } else {
      // Insert new record
      await db.insert(
        'albums',
        {
          'album_id': albumId,
          'name': name ?? 'Unknown',
          'session': session,
          'cover': cover,
        },
      );
    }
  }

  Future<void> insertAlbums(List<Album> albums) async {
    final db = await database;
    final batch = db.batch();
    final session = ApplicationConfig().sessionId;

    for (var album in albums) {
      // Check if record exists with same album_id and session
      final List<Map<String, dynamic>> existing = await db.query(
        'albums',
        where: 'album_id = ? AND session = ?',
        whereArgs: [album.id, session],
      );

      if (existing.isNotEmpty) {
        // Update existing record
        await db.update(
          'albums',
          {
            'name': album.name ?? 'Unknown',
            'cover': album.cover,
          },
          where: 'album_id = ? AND session = ?',
          whereArgs: [album.id, session],
        );
      } else {
        // Insert new record
        batch.insert(
          'albums',
          {
            'album_id': album.id,
            'name': album.name ?? 'Unknown',
            'session': session,
            'cover': album.cover,
          },
        );
      }
    }
    await batch.commit();
  }

  Future<List<Album>> getAllAlbums() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('albums');
    return maps
        .map((map) => Album.fromJson({
              'id': map['album_id'],
              'name': map['name'],
              'cover': map['cover'],
            }))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAlbumsBySession(String session) async {
    final db = await database;
    return await db.query(
      'albums',
      where: 'session = ?',
      whereArgs: [session],
    );
  }

  Future<void> deleteAlbum(int albumId) async {
    final db = await database;
    await db.delete(
      'albums',
      where: 'album_id = ?',
      whereArgs: [albumId],
    );
  }

  Future<void> deleteAllAlbums() async {
    final db = await database;
    await db.delete('albums');
  }
}
