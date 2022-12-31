--[[Equip only to a Plant Monster. If is is a Level 3 or lower Monster: It gains 1000 ATK. 
The equipped monster cannot be targeted or destroyed by your opponents card effects. 
If this card is sent to the GY by a monster effect: You can target 1 Plant Monster in your GY: 
Special Summon it.]]

function c79854539.initial_effect(c)
--ATKboost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c79854539.atkval)
	c:RegisterEffect(e1)
--cannot be targeted or destroyed by card effects
		--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
		--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c79854539.indval)
	c:RegisterEffect(e3)
--special Summon effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79854539,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c79854539.srcon)
	e4:SetTarget(c79854539.srtg)
	e4:SetOperation(c79854539.srop)
	c:RegisterEffect(e4)
	--equiplimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c79854539.eqlimit)
	c:RegisterEffect(e5)
	--Activate
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_ACTIVATE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetTarget(c79854539.actarget)
	e6:SetOperation(c79854539.acoperation)
	c:RegisterEffect(e6)
end
--Euipfilter
function c79854539.eqlimit(e,c)
	return c:IsRace(RACE_PLANT)
end
--ATKboost
function c79854539.atkval(e,c)
	if c:IsLevelBelow(3) then return 1000 else return 0 end
end
--indes
function c79854539.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
--sseffect
function c79854539.srcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) and e:GetHandler():IsReason(REASON_COST)) or
	(re:IsActiveType(TYPE_MONSTER) and bit.band(r,REASON_EFFECT)~=0)
end
function c79854539.srtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79854539.srfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c79854539.srfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c79854539.srfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c79854539.srfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c79854539.srop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--activate
function c79854539.acfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
function c79854539.actarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c79854539.acfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c79854539.acfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c79854539.acfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c79854539.acoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end