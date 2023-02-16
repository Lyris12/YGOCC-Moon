--Symphaenic Reviere
local ref,id=GetID()
function ref.initial_effect(c)
	c:SetUniqueOnField(LOCATION_ONFIELD,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(ref.target)
	e1:SetOperation(ref.activate)
	c:RegisterEffect(e1)
	--Revive
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(ref.sscost(0))
	e2:SetTarget(ref.sstg(LOCATION_GRAVE))
	e2:SetOperation(ref.ssop(LOCATION_GRAVE))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCode(EVENT_REMOVE)
	e3:SetTarget(ref.sstg(LOCATION_REMOVED))
	e3:SetOperation(ref.ssop(LOCATION_REMOVED))
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCost(ref.sscost(1))
	e4:SetCondition(ref.regcon)
	e4:SetOperation(ref.regop)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCondition(ref.regcon)
	e5:SetCost(ref.sscost(1))
	e5:SetOperation(ref.regop)
	c:RegisterEffect(e5)
end

--Activate
function ref.thfilter(c)
	return c:IsSetCard(0x255) and c:IsAbleToHand()
end
function ref.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function ref.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end

--Revive
function ref.sscost(val)
	return function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		local ct=Duel.GetFlagEffect(tp,id)
		if chk==0 then return (ct==val) and c:GetFlagEffect(id)==0 end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,ct+1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,1,aux.Stringid(id,5))
	end
end
function ref.ssfilter(c,e,tp,loc,chk)
	return c:IsSetCard(0x255) and c:IsLocation(loc) and c:IsFaceup()
		and (chk or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function ref.sstg(loc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		local g=eg:Filter(ref.ssfilter,nil,e,tp,loc)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and #g>0
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
function ref.ssop(loc)
	return function(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local g=eg:Filter(ref.ssfilter,nil,e,tp,loc)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--Pend
function ref.regcfilter(c) return c:IsSetCard(0x255) and c:IsFaceup() end
function ref.regcon(e,tp,eg) return eg:IsExists(ref.regcfilter,1,nil) end
function ref.regop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(ref.pndcon)
	e1:SetOperation(ref.pndop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function ref.pndfilter(c)
	return c:IsType(TYPE_PENDULUM)
end
function ref.pndcon(e,tp)
	return Duel.IsExistingMatchingCard(ref.pndfilter,tp,LOCATION_DECK,0,1,nil)
end
function ref.pndop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectMatchingCard(tp,ref.pndfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoExtraP(g,tp,REASON_EFFECT) end
end
