--Sextus dell'Organizzazione Angeli, Trisalba
--Script by XGlitchy30
function c16599468.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,c16599468.tunermat,aux.NonTuner(c16599468.nontuner),1)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,16599468)
	--synchro summon
	local s1=Effect.CreateEffect(c)
	s1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	s1:SetType(EFFECT_TYPE_SINGLE)
	s1:SetCode(EFFECT_SPSUMMON_CONDITION)
	s1:SetValue(aux.synlimit)
	c:RegisterEffect(s1)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599468.efilter)
	c:RegisterEffect(e0)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c16599468.rmcon)
	e1:SetCost(c16599468.rmcost)
	e1:SetTarget(c16599468.rmtg)
	e1:SetOperation(c16599468.rmop)
	c:RegisterEffect(e1)
	--field effect
	-- local e1x=Effect.CreateEffect(c)
	-- e1x:SetType(EFFECT_TYPE_FIELD)
	-- e1x:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- e1x:SetRange(LOCATION_MZONE)
	-- e1x:SetTargetRange(LOCATION_MZONE,0)
	-- e1x:SetTarget(c16599468.fieldfilter)
	-- e1x:SetValue(1)
	-- c:RegisterEffect(e1x)
	-- local e1y=e1x:Clone()
	-- e1y:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- c:RegisterEffect(e1y)
	--reflect damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c16599468.damcon)
	e2:SetTarget(c16599468.damtg)
	e2:SetOperation(c16599468.damop)
	c:RegisterEffect(e2)
	--keep on field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetTarget(c16599468.regop)
	c:RegisterEffect(e3)
end
--filters
function c16599468.tunermat(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY) and c:GetLevel()>=7
end
function c16599468.nontuner(c)
	return c:IsRace(RACE_FAIRY) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c16599468.mfilter(c,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_SYNCHRO)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsAbleToRemoveAsCost()
end
function c16599468.chlimit(e,ep,tp)
	return tp==ep
end
function c16599468.fieldfilter(e,c)
	return c:IsRace(RACE_FAIRY) and c~=e:GetHandler()
end
function c16599468.replacer(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemove()
end
--target protection
function c16599468.efilter(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--wipe field
function c16599468.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c16599468.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local synmat=mat:Filter(c16599468.mfilter,nil,tp,c)
	if chk==0 then return synmat:GetCount()>0 and mat:FilterCount(c16599468.mfilter,nil,tp,c)==synmat:GetCount() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=synmat:Select(tp,synmat:GetCount(),synmat:GetCount(),nil)
	if g:GetCount()==synmat:GetCount() then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599468.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetChainLimit(c16599468.chlimit)
end
function c16599468.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
--reflect damage
function c16599468.damcon(e,tp,eg,ep,ev,re,r,rp)
	local att=Duel.GetAttacker()
	local def=Duel.GetAttackTarget()
	return ep==tp and att and def
		and ((att:GetControler()==tp and att:IsRace(RACE_FAIRY) and att:IsRelateToBattle())
		or (def:GetControler()==tp and def:IsRace(RACE_FAIRY) and def:IsRelateToBattle()))
end
function c16599468.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
function c16599468.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
--keep on field
function c16599468.regop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (c:GetDestination()==LOCATION_GRAVE or c:GetDestination()==LOCATION_REMOVED or c:GetDestination()==LOCATION_HAND or c:GetDestination()==LOCATION_EXTRA or c:GetDestination()==LOCATION_DECK) 
		and Duel.IsExistingMatchingCard(c16599468.replacer,tp,LOCATION_DECK,0,1,e:GetHandler()) 
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetFlagEffect(16599468)<1 and c:IsReason(REASON_BATTLE+REASON_EFFECT)
	end
	if Duel.SelectYesNo(tp,aux.Stringid(16599468,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c16599468.replacer,tp,LOCATION_DECK,0,1,1,e:GetHandler())
		if g:GetCount()>0 then
			Duel.MoveSequence(g:GetFirst(),0)
			Duel.ConfirmDecktop(tp,1)
			if Duel.Remove(g:GetFirst(),POS_FACEDOWN,REASON_REPLACE)~=0 then
				Duel.ShuffleDeck(tp)
				c:RegisterFlagEffect(16599468,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
				return true
			end
		end
	else return false end
end