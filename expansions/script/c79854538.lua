--[[Equip only to a Plant Monster. If is is a Level 3 or lower Monster: It gains 1000 ATK. 
During your Main Phase: You can target 1 Level 4 or lower Plant Monster in your GY; Special Summon
 it. If the equipped Monster is removed from the field, banish all monsters Special Summoned by 
 this effect. If this card is sent to the GY by a monster effect: You can add 1 Equip Spell 
 from your Deck to your hand. You can only use each effect of "Plantkings Scepter" once per turn.]]

function c79854538.initial_effect(c)

--ATKboost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c79854538.atkval)
	c:RegisterEffect(e1)
--special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79854538,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,79854538)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c79854538.target)
	e2:SetOperation(c79854538.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c79854538.descon)
	e3:SetOperation(c79854538.desop)
	c:RegisterEffect(e3)
--search effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79854538,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,79854638)
	e4:SetCondition(c79854538.srcon)
	e4:SetTarget(c79854538.srtg)
	e4:SetOperation(c79854538.srop)
	c:RegisterEffect(e4)
--equiplimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c79854538.eqlimit)
	c:RegisterEffect(e5)
--Activate
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_ACTIVATE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetTarget(c79854538.actarget)
	e6:SetOperation(c79854538.acoperation)
	c:RegisterEffect(e6)
end
--Euipfilter
function c79854538.eqlimit(e,c)
	return c:IsRace(RACE_PLANT)
end
--ATKboost
function c79854538.atkval(e,c)
	if c:IsLevelBelow(3) then return 1000 else return 0 end
end
--special summon
function c79854538.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c79854538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79854538.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c79854538.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c79854538.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c79854538.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		c:SetCardTarget(tc)
	end
end
function c79854538.desfilter(c,rc)
	return rc:GetCardTarget():IsContains(c)
end
function c79854538.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and not ec:IsLocation(LOCATION_ONFIELD+LOCATION_OVERLAY)
end
function c79854538.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()>0 then
		local dg=Duel.GetMatchingGroup(c79854538.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
	end
end
function c79854538.srcon(e,tp,eg,ep,ev,re,r,rp)
	return re and ((re:IsActiveType(TYPE_MONSTER) and e:GetHandler():IsReason(REASON_COST)) or
	(re:IsActiveType(TYPE_MONSTER) and bit.band(r,REASON_EFFECT)~=0))
 end
function c79854538.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c79854538.srfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c79854538.srfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand() and not c:IsCode(79854538)
end
function c79854538.srop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c79854538.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--activate
function c79854538.acfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
function c79854538.actarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c79854538.acfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c79854538.acfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c79854538.acfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c79854538.acoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end