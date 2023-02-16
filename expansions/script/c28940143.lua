--Symphaenic Blues
local ref,id=GetID()
function ref.initial_effect(c)
	c:SetUniqueOnField(LOCATION_ONFIELD,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	--e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
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
	e3:SetCode(EVENT_TO_DECK)
	e3:SetTarget(ref.sstg(LOCATION_EXTRA))
	e3:SetOperation(ref.ssop(LOCATION_EXTRA))
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCondition(ref.regcon)
	e4:SetCost(ref.sscost(1))
	e4:SetOperation(ref.regop)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCondition(ref.regcon)
	e5:SetCost(ref.sscost(1))
	e5:SetOperation(ref.regop)
	c:RegisterEffect(e5)
end

--Activate
function ref.thfilter(c)
	return c:IsSetCard(0x255) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function ref.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,300)
end
function ref.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,val,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0x255) end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetValue(val)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
	local dg=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,0,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sdg=dg:Select(tp,1,1,nil)
		Duel.Destroy(sdg,REASON_EFFECT)
	end
end

--Revive
function ref.sscost(val)
	return function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		local ct=Duel.GetFlagEffect(tp,id)
		if chk==0 then return (ct==val) and c:GetFlagEffect(id)==0 end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,ct+1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
	end
end
function ref.ssfilter(c,e,tp)
	return c:IsSetCard(0x255) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (Duel.GetLocationCountFromEx(tp)>0 or not c:IsLocation(LOCATION_EXTRA))
end
function ref.sstg(loc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		local g=eg:Filter(ref.ssfilter,nil,e,tp)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and #g>0
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,1,aux.Stringid(id,5))
	end
end
function ref.ssop(loc)
	return function(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local g=eg:Filter(ref.ssfilter,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--Foolish
function ref.regcfilter(c) return c:IsSetCard(0x255) and c:IsFaceup() end
function ref.regcon(e,tp,eg) return eg:IsExists(ref.regcfilter,1,nil) end
function ref.regop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(ref.grcon)
	e1:SetOperation(ref.grop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function ref.grfilter(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() end
function ref.grcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK,0,1,nil)
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
