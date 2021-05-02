--created & coded by Lyris, art by Chahine Sfar & generalzoi of DeviantArt
--「S・VINE」ペガサス
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(s.tfcon)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_COST)
	e4:SetOperation(s.sumcost)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_FLIPSUMMON_COST)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_SUMMON_COST)
	c:RegisterEffect(e6)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fdtg)
	e2:SetOperation(s.fdop)
	c:RegisterEffect(e2)
end
function s.tfcfilter(c)
	return c:IsPosition(POS_FACEUP) and c:IsSetCard(0x285b) and not c:IsCode(id)
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tfcfilter,1,nil)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x285b) and c:IsAbleToGraveAsCost()
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,nil)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED,0,1,3,nil)
	local ct=Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300*ct)
	c:RegisterEffect(e1)
end
function s.lvcon(e)
	local c=e:GetHandler()
	return (Card.IsSummonType and not c:IsSummonType(SUMMON_TYPE_ADVANCE))
		or (bit.band and bit.band(c:GetSummonType(),SUMMON_TYPE_ADVANCE)~=SUMMON_TYPE_ADVANCE)
		or c:GetSummonType()&SUMMON_TYPE_ADVANCE~=SUMMON_TYPE_ADVANCE
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.lvcon)
	e2:SetValue(1400)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
function s.thfilter(c)
	return c:IsSetCard(0x285b) and c:IsAbleToHand()
end
function s.trfilter(c)
	return c:IsSetCard(0x285b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.trfilter,tp,LOCATION_DECK,0,1,nil) and (c:GetFlagEffect(id)==0 or bit.band(c:GetFlagEffectLabel(id),0x1)~=0x1)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and (c:GetFlagEffect(id)==0 or bit.band(c:GetFlagEffectLabel(id),0x2)~=0x2)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,5))
	else op=Duel.SelectOption(tp,aux.Stringid(id,6))+1 end
	e:SetLabel(op)
	if op~=0 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(Duel.SelectMatchingCard(tp,s.trfilter,tp,LOCATION_DECK,0,1,1,nil),POS_FACEUP,REASON_EFFECT)
		if c:GetFlagEffect(id)==0 then
			c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1,0x1)
		else c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)|0x1) end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if c:GetFlagEffect(id)==0 then
			c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1,0x2)
		else
			c:SetFlagEffectLabel(id,bit.bor(c:GetFlagEffectLabel(id),0x2))
		end
	end
end
