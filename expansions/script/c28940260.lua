--Marionightte Top Billing
local ref,id=GetID()
function ref.initial_effect(c)
	--Activate with monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(ref.actcon)
	e1:SetTarget(ref.acttg)
	c:RegisterEffect(e1)
	--Activate (Special Summon)
	--[[local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<1 end)
	e2:SetTarget(ref.dktg)
	e2:SetOperation(ref.dkop)
	c:RegisterEffect(e2)]]
	--On Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(ref.grcon)
	e3:SetTarget(ref.grtg)
	e3:SetOperation(ref.grop)
	c:RegisterEffect(e3)
	--If ED Monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(ref.hdcon)
	e4:SetTarget(ref.hdtg)
	e4:SetOperation(ref.hdop)
	c:RegisterEffect(e4)
end

--Special Summon (general)
function ref.ssfilter(c,e,tp,rc)
	return aux.IsCodeListed(c,rc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Activate
function ref.actcon(e,tp)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<1 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetHandler())
	else return true end
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<1 then
		e:SetOperation(ref.dkop)
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		e:SetOperation(function() return end)
		e:SetCategory(0)
	end
end
function ref.dktg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.dkop(e,tp) local c=e:GetHandler()
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,c)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(ref.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function ref.actlimit(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
		and not (Duel.CheckEvent(EVENT_SUMMON_SUCCESS) or Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) or Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS))
end

--On Destroy
function ref.grcfilter(c,tp) return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp end
function ref.grcon(e,tp,eg) return eg:IsExists(ref.grcfilter,1,nil,tp) end
function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and ref.ssfilter(chkc,e,tp,c) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(ref.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,ref.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

--If ED Monster
function ref.hdcon(e,tp)
	return Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function ref.hdtg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c)
		--and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	--Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function ref.hdop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,c)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end --then Duel.Draw(tp,1,REASON_EFFECT) end
end
