extends Node

const FILE_PATH := "res://donation_receive.csv" #ตัวรับโดเนท
const QUEUE_FILE_PATH := "res://donation_queue.csv" #ตัวเรียงคิวโดเนท

func _ready():
	#ตอนเริ่มเกมไม่ควรมีข้อมูลพวกนี้เหลือ
	# Clear the contents of the donation_receive.csv file
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if file:
		file.close()

	# Clear the contents of the QueueDonate.csv file
	var queue_file = FileAccess.open(QUEUE_FILE_PATH, FileAccess.WRITE)
	if queue_file:
		queue_file.close()

	#เรียกเช้คว่ามีโดเนทใหม่ไหม ทุก 1 วิ
	$DonateTimer.start()

func Read_donate():
	# Open the donation_receive.csv file in read mode to process it
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	if file:
		# Open the QueueDonate.csv file in append mode to write the data
		var queue_file = FileAccess.open(QUEUE_FILE_PATH, FileAccess.READ_WRITE) #อ่านละค่อยเขียน
		if queue_file:
			queue_file.seek_end()  # Move the file cursor to the end for appending
			while !file.eof_reached(): #อ่านจนหมดทั้งไฟล์
				var csv_line = file.get_csv_line(",")
				if csv_line.size() > 1:  # Check if there are at least two elements in the array
					var donor = csv_line[0]
					var amount = csv_line[1]
					#print(donor + "," + amount)
					queue_file.store_string(donor + "," + amount + "\n")
					#print("Stored a line in queue")
				else:
					pass
					#print("Skipping invalid CSV line:", csv_line) #ไม่มีโดเนท
			queue_file.close()
		else:
			pass
			#print("Can't open Donation Queue")
		file.close()
		#เคลียไฟล์หลังจากย้ายไปคิว
		var filew = FileAccess.open(FILE_PATH, FileAccess.WRITE)
		if filew:
			filew.close()
	else:
		pass
		#print("Can't open Donation Receive")
	#print("End of function")

func _on_donate_timer_timeout():
	Read_donate()
