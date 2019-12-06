module textedit.models.setting;

import hunt.entity;

@Table("setting")
class Setting : Model
{
	mixin MakeModel;

	@PrimaryKey
	string name;

	string value;
}