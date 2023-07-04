extends Control

const fileName:String = "main.pak"
const outName:String = "main.de.pak"

func _ready():
	await get_tree().create_timer(0.5).timeout
	unpack()
	extract()

#解密文件
func unpack():
	var fileArray:PackedByteArray = FileAccess.get_file_as_bytes(fileName)
	var unpackArray:PackedByteArray = PackedByteArray()
	for byte in fileArray:
		var temp = byte ^ 0xf7
		unpackArray.append(temp)
	
	var file = FileAccess.open(outName,FileAccess.WRITE)
	file.store_buffer(unpackArray)
	file.close()
	print("导出完成")
	
#导出资源
func extract():
	var file = FileAccess.open(outName, FileAccess.READ)
	file.big_endian = false
	file.seek(9)
	
	#获取文件列表
	var fileArray:Array[Dictionary] = []
	while true:
		var l = file.get_8()
		var nameStr:PackedByteArray = file.get_buffer(l)
		print(nameStr.get_string_from_utf8())
		var fileLen = file.get_buffer(4)
		var noUse = file.get_buffer(8)
		var end = file.get_buffer(1)
		fileArray.append({"name":nameStr.get_string_from_utf8(),"len":fileLen.decode_s32(0)})
#		break
		if end[0] == 0x80:
			break

	var dir = DirAccess.open("D:/")
	if not dir.dir_exists("pvz_extract"):
		dir.make_dir("pvz_extract")

	#写入文件
	for f in fileArray:
		struct_write(f,file)
	
	print("处理完成")

#写入文件
func struct_write(fileInfo:Dictionary,file:FileAccess):
	var fullPath:String = fileInfo["name"]
	var folderPath:String = fullPath.get_base_dir()
	var fileName = fullPath.get_file()
	prep_path(folderPath)
	var extractFile = FileAccess.open("D:/pvz_extract/" + fullPath, FileAccess.WRITE)
	var buffer = file.get_buffer(fileInfo["len"])
	extractFile.store_buffer(buffer)
	extractFile.close()
	
#创建文件夹
func prep_path(folderPath:String):
	var dir = DirAccess.open("D:/pvz_extract")
	var folderPathArray = folderPath.split("\\")
	for folder in folderPathArray:
		if not dir.dir_exists(folder):
			dir.make_dir(folder)
		dir.change_dir(folder)
	
