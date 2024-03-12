--created by Jake, coded by Lyris
--Dawn Blader - Jonah the Prince
if not global_override_reason_effect_check then
	global_override_reason_effect_check = true
end
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddSetNameMonsterList(c,0x613)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x613) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetLabelObject(e)
		e1:SetOperation(s.leave)
		e1:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD+RESET_OVERLAY)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local oc=e:GetOwner()
	local rs=c:GetReason()|REASON_DISCARD
	local r=r
	local re=re
	if rs&(REASON_COST|REASON_EFFECT)<1 then rs=rs|REASON_EFFECT end
	if r&(REASON_COST|REASON_EFFECT)<1 then r=r|REASON_EFFECT end
	c:SetReason(rs)
	if not re then re=e:GetLabelObject() end
	if not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613)) then
		if not s.scapetoken then
			local token=Duel.CreateToken(tp,GLITCHY_UNIVERSAL_TOKEN)
			token:SetStatus(STATUS_NO_LEVEL,true)
			s.scapetoken=token
		end
		s.scapetoken:Recreate(id,0,0x613,(s.scapetoken:GetType()&~TYPE_NORMAL)|oc:GetType(),0,0,0,0)
		local fake_re=re:Clone()
		s.scapetoken:RegisterEffect(fake_re,true)
		fake_re:SetCheatCode(GECC_OVERRIDE_ACTIVE_TYPE)
		re:SetCheatCode(GECC_OVERRIDE_REASON_EFFECT,true,fake_re)
	end
	Duel.RaiseSingleEvent(c,EVENT_DISCARD,re,r,rp,tp,0)
	Duel.RaiseEvent(c,EVENT_DISCARD,re,r,rp,tp,0)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613) and e:GetHandler():IsReason(REASON_EFFECT+REASON_COST)
end
function s.sfilter(c)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
