extends Node

const TRANSITION_TIME = 0.3

static func create_tween_fade(node: CanvasItem, to_value: float, duration: float = TRANSITION_TIME) -> Tween:
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", to_value, duration)
	return tween

static func create_tween_scale(node: Node2D, to_scale: Vector2, duration: float = TRANSITION_TIME) -> Tween:
	var tween = node.create_tween()
	tween.tween_property(node, "scale", to_scale, duration).set_trans(Tween.TRANS_BACK)
	return tween

static func create_tween_position(node: Node2D, to_position: Vector2, duration: float = TRANSITION_TIME) -> Tween:
	var tween = node.create_tween()
	tween.tween_property(node, "position", to_position, duration).set_trans(Tween.TRANS_CUBIC)
	return tween

static func create_tween_rotation(node: Node2D, to_rotation: float, duration: float = TRANSITION_TIME) -> Tween:
	var tween = node.create_tween()
	tween.tween_property(node, "rotation", to_rotation, duration).set_trans(Tween.TRANS_CUBIC)
	return tween

static func create_card_draw_animation(card: Node2D, start_pos: Vector2, end_pos: Vector2) -> Tween:
	card.position = start_pos
	card.scale = Vector2.ZERO
	card.rotation = -PI/4
	
	var tween = card.create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "position", end_pos, TRANSITION_TIME * 2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "scale", Vector2.ONE, TRANSITION_TIME * 2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(card, "rotation", 0, TRANSITION_TIME * 2).set_trans(Tween.TRANS_CUBIC)
	return tween

static func create_card_play_animation(card: Node2D, target_pos: Vector2) -> Tween:
	var tween = card.create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "position", target_pos, TRANSITION_TIME).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "scale", Vector2(1.2, 1.2), TRANSITION_TIME/2).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(card, "scale", Vector2.ONE, TRANSITION_TIME/2).set_trans(Tween.TRANS_CUBIC)
	return tween

static func create_card_hover_animation(card: Node2D, hover: bool) -> Tween:
	var scale = Vector2(1.1, 1.1) if hover else Vector2.ONE
	var y_offset = -20 if hover else 0
	
	var tween = card.create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "scale", scale, TRANSITION_TIME/2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "position:y", card.position.y + y_offset, TRANSITION_TIME/2).set_trans(Tween.TRANS_CUBIC)
	return tween

static func create_shake_animation(node: Node2D, intensity: float = 5.0, duration: float = 0.5) -> Tween:
	var tween = node.create_tween()
	var original_position = node.position
	
	for i in range(10):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(node, "position", original_position + offset, duration/10)
	
	tween.tween_property(node, "position", original_position, duration/10)
	return tween

static func create_particle_effect(scene: Node2D, effect_scene: PackedScene, position: Vector2) -> Node2D:
	var effect = effect_scene.instantiate()
	effect.position = position
	scene.add_child(effect)
	return effect
