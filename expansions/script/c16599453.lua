--Spectator dell'Organizzazione Angeli, Mysty
--=£1G*
function c16599453.initial_effect(c)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599453.efilter)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,16599453)
	e1:SetCondition(c16599453.sccon)
	e1:SetCost(c16599453.sccost)
	e1:SetTarget(c16599453.sctg)
	e1:SetOperation(c16599453.scop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,15599453)
	e2:SetCondition(c16599453.spcon)
	e2:SetTarget(c16599453.sptg)
	e2:SetOperation(c16599453.spop)
	c:RegisterEffect(e2)
end
--filters
function c16599453.tkfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetLevel()>lv
end
function c16599453.costfilter(c,lv)
	return c:IsRace(RACE_FAIRY) and c:GetLevel()>lv and c:IsAbleToRemoveAsCost()
end
function c16599453.scfilter(c,code)
	return c:IsSetCard(0x1559) and c:IsAbleToHand() and c:GetCode()~=code and (c:IsLocation(LOCATION_DECK) or (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)))
end
function c16599453.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1559) and re:GetHandler():GetLevel()==e:GetHandler():GetLevel() and not re:GetHandler():IsType(TYPE_SYNCHRO)
		and not re:GetHandler():IsCode(16599453)
end
--target protection
function c16599453.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(3)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=3)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--spsummon
function c16599453.sccon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsExistingMatchingCard(c16599453.tkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e:GetHandler():GetLevel())
		or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1)
end
function c16599453.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599453.costfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler(),e:GetHandler():GetLevel()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599453.costfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,e:GetHandler(),e:GetHandler():GetLevel())
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		local op=Duel.GetOperatedGroup():GetFirst()
		if op then
			e:SetLabel(op:GetCode())
		end
	end
end
function c16599453.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local code=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(c16599453.scfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,code) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function c16599453.scop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c16599453.scfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,code)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--activation limit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c16599453.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--spsummon
function c16599453.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) --and e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
function c16599453.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c16599453.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			c:RegisterFlagEffect(16599453,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			c:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			c:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e3:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e3,true)
			-- local e3=Effect.CreateEffect(c)
			-- e3:SetType(EFFECT_TYPE_SINGLE)
			-- e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			-- e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			-- e3:SetReset(RESET_EVENT+0x47e0000)
			-- e3:SetValue(LOCATION_GRAVE)
			-- c:RegisterEffect(e3,true)
			-- local e4=Effect.CreateEffect(c)
			-- e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			-- e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			-- e4:SetCode(EVENT_LEAVE_FIELD_P)
			-- --e4:SetLabelObject(e3)
			-- e4:SetCondition(c16599453.rdcon)
			-- e4:SetOperation(c16599453.rdprev)
			-- e4:SetReset(RESET_EVENT+0x47e0000)
			-- c:RegisterEffect(e4,true)
			Duel.SpecialSummonComplete()
		end
	end
end
-- function c16599453.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- return e:GetHandler():GetFlagEffect(26599453)<=0
-- end
-- function c16599453.rdprev(e,tp,eg,ep,ev,re,r,rp)
	-- e:GetHandler():RegisterFlagEffect(26599453,RESET_CHAIN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
	-- -- local redirect=e:GetLabelObject()
	-- -- if not redirect then return Damage(e:GetHandler():GetControler(),1,REASON_EFFECT) end
	-- if e:GetHandler():GetDestination()==LOCATION_GRAVE then
		-- local redirect=Effect.CreateEffect(e:GetHandler())
		-- redirect:SetType(EFFECT_TYPE_SINGLE)
		-- redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		-- redirect:SetCode(EFFECT_CANNOT_TO_GRAVE)
		-- redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+16599453)
		-- e:GetHandler():RegisterEffect(redirect)
		-- Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_RULE)
	-- elseif e:GetHandler():GetDestination()==LOCATION_HAND then
		-- local redirect=Effect.CreateEffect(e:GetHandler())
		-- redirect:SetType(EFFECT_TYPE_SINGLE)
		-- redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		-- redirect:SetCode(EFFECT_CANNOT_TO_HAND)
		-- redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+16599453)
		-- e:GetHandler():RegisterEffect(redirect)
		-- Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_RULE)
	-- elseif (e:GetHandler():GetDestination()==LOCATION_DECK or e:GetHandler():GetDestination()==LOCATION_EXTRA) then
		-- local redirect=Effect.CreateEffect(e:GetHandler())
		-- redirect:SetType(EFFECT_TYPE_SINGLE)
		-- redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		-- redirect:SetCode(EFFECT_CANNOT_TO_DECK)
		-- redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+16599453)
		-- e:GetHandler():RegisterEffect(redirect)
		-- Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_RULE)
	-- else
		-- local redirect=Effect.CreateEffect(e:GetHandler())
		-- redirect:SetType(EFFECT_TYPE_SINGLE)
		-- redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		-- redirect:SetCode(EFFECT_CANNOT_REMOVE)
		-- redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+16599453)
		-- e:GetHandler():RegisterEffect(redirect)
		-- Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_RULE)
	-- end
	-- Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+16599453,e,0,tp,tp,0)
	-- Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+16599453,e,0,tp,tp,0)
-- end