--VECTOR Frame: Vylte
--Scripted by Zerry
function c67864675.initial_effect(c)
--Equipping
local e1=Effect.CreateEffect(c)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
e1:SetCategory(CATEGORY_EQUIP)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_TO_GRAVE)
e1:SetCountLimit(1,67864675+100)
e1:SetCondition(c67864675.eqcon)
e1:SetTarget(c67864675.eqtg)
e1:SetOperation(c67864675.eqop)
c:RegisterEffect(e1)
--Recycle
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(67864675,1))
e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetCode(EVENT_SUMMON_SUCCESS)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
e2:SetCountLimit(1,67864675)
e2:SetTarget(c67864675.thtg)
e2:SetOperation(c67864675.thop)
c:RegisterEffect(e2)
local e3=e2:Clone()
e3:SetCode(EVENT_SPSUMMON_SUCCESS)
e3:SetCondition(c67864675.thcon)
c:RegisterEffect(e3)
--Equip Stats
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_EQUIP)
e4:SetCode(EFFECT_UPDATE_ATTACK)
e4:SetValue(300)
c:RegisterEffect(e4)
local e5=Effect.CreateEffect(c)
e5:SetType(EFFECT_TYPE_EQUIP)
e5:SetCode(EFFECT_UPDATE_DEFENSE)
e5:SetValue(300)
c:RegisterEffect(e5)
local e6=Effect.CreateEffect(c)
e6:SetType(EFFECT_TYPE_SINGLE)
e6:SetCode(EFFECT_EQUIP_LIMIT)
e6:SetValue(c67864675.eqlimit)
c:RegisterEffect(e6)
end
--Recycle
function c67864675.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc:IsRace(RACE_CYBERSE) and rc:IsSetCard(0x2a6)
end
function c67864675.filter(c)
	return c:IsSetCard(0x2a6)
end
function c67864675.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c67864675.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c67864675.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c67864675.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--Equip
function c67864675.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c67864675.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a6)
end
function c67864675.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67864675.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c67864675.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c67864675.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c67864675.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		if not Duel.Equip(tp,c,tc) then return end
end
end
function c67864675.eqlimit(e,c)
	return (c:IsSetCard(0x2a6) or e:GetHandler():GetEquipTarget()==c)
end