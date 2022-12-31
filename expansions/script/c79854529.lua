--If your opponent controls a Monster and all Monsters (if any) that you control are Plant Monsters:
-- You can Special Summon this card (from your hand). Once per turn, during either players turn: 
--You can target 1 Plant Monster in your GY; This cards Level becomes equal to the targets level.

function c79854529.initial_effect(c)
--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79854529.spcon)
	c:RegisterEffect(e1)
--lv change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79854529,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c79854529.lvtg)
	e2:SetOperation(c79854529.lvop)
	c:RegisterEffect(e2)
end
--Special Summon
function c79854529.cfilter(c)
	return (c:IsFacedown() or not c:IsRace(RACE_PLANT)) and c:IsType(TYPE_MONSTER)
end
function c79854529.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and not Duel.IsExistingMatchingCard(c79854529.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--lvchange
function c79854529.filter(c,clv)
	local lv=c:GetLevel()
	return c:IsRace(RACE_PLANT) and lv~=0 and lv~=clv
		and c:IsLocation(LOCATION_GRAVE)
end
function c79854529.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c79854529.filter(chkc,e:GetHandler():GetLevel()) end
	if chk==0 then return Duel.IsExistingTarget(c79854529.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e:GetHandler():GetLevel()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c79854529.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler(),e:GetHandler():GetLevel())
end
function c79854529.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
		and (not tc:IsLocation(LOCATION_MZONE) or tc:IsFaceup()) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+0x1ff0000)
		e:GetHandler():RegisterEffect(e1)
	end
end