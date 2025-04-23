extends Node

var run_queue = false
var otherLine = [] # Initialize as an empty array
const FILE_PATH := "res://donation_queue.csv"

@onready var name_label: Label = $"../dono_name"
@onready var amount_label: Label = $"../dono_value"

func _ready():
	if run_queue == false:
		run_queue = true
		#print("Queue Start")
		$QueueTimer.start()
	else:
		run_queue = false
		#print("Queue Stop")
		$QueueTimer.stop()

func read_queue():
	#print("Queue running")
	otherLine = [] #เคลียข้อมูลกันซ้ำ
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	if file:
		var csv_line = file.get_csv_line(",")
		if csv_line.size() > 1:
			var donor = csv_line[0]
			var amount = csv_line[1].to_int()
			if amount == 99:
				name_label.text = "WOW"
				amount_label.text = "999999"
			else:
				name_label.text = donor
				amount_label.text = str(amount)
			
			#print(donor + "," + amount)
			#if amount == 20:
			#	$"../../DonateSpawner".spawnenemy(donor)
			#	await get_tree().create_timer(0.5).timeout
			#	$"../../DonateSpawner".spawnenemy(donor)
			#	print("wow 20 bath")
			#elif amount == 100:
			#	$"../../DonateSpawner".spawnfireballstorm()
			#else:
			#	$"../../DonateSpawner".spawnenemy(donor)
			
			while !file.eof_reached():
				var line = file.get_csv_line(",")
				if line.size() > 1:
					otherLine.append(line) #ทำข้อมูลต่อกัน EX: [[atom,100], [medh,10],[เพิ่มไปเรื่อยๆ]
		else:
			print("No Queue")
	#print(otherLine)
	reorder_queue()

func reorder_queue():
	var filew = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if filew:
		# Clear existing content
		filew.close()
	filew = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if filew:
		for line in otherLine: #แต่ละแถว
			var csv_line = ""
			for item in line: #แต่ละ Item
				csv_line += str(item) + "," # EX: Atom,100,
			csv_line = csv_line.substr(0, csv_line.length() - 1) #เอาคอมม่าออก EX: Atom,100
			filew.store_string(csv_line + "\n") #เก็บ

func _on_queue_timer_timeout():
	read_queue()
