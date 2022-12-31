--Exsecutor dell'Organizzazione Angeli, Dracodia
--Script by XGlitchy30
function c16599454.initial_effect(c)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599454.efilter)
	c:RegisterEffect(e0)
	--avoid battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16599454.bfilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--change levels
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16599454)
	e2:SetLabel(0)
	e2:SetCost(c16599454.lvcost)
	e2:SetTarget(c16599454.lvtg)
	e2:SetOperation(c16599454.lvop)
	c:RegisterEffect(e2)
	--change control
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(c16599454.chgcon)
	e3:SetTarget(c16599454.chgtg)
	e3:SetOperation(c16599454.chgop)
	c:RegisterEffect(e3)
	--register damage
	-- local ge0=Effect.CreateEffect(c)
	-- ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- ge0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	-- ge0:SetCode(EVENT_DAMAGE)
	-- ge0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	-- ge0:SetCondition(c16599454.regcon)
	-- ge0:SetOperation(c16599454.register)
	-- c:RegisterEffect(ge0)
	-- --register summon
	-- local ge1=Effect.CreateEffect(c)
	-- ge1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	-- ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	-- ge1:SetCode(EVENT_SUMMON_SUCCESS)
	-- ge1:SetOperation(c16599454.regop)
	-- c:RegisterEffect(ge1)
	-- local ge2=ge1:Clone()
	-- ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- c:RegisterEffect(ge2)
	-- local ge3=ge1:Clone()
	-- ge3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- c:RegisterEffect(ge3)
end
-----CHECK and REGISTER BATTLE DAMAGE\SUMMON-----
-- function c16599454.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- local att=Duel.GetAttacker()
	-- local def=Duel.GetAttackTarget()
	-- return att and def and ep==tp and bit.band(r,REASON_BATTLE)~=0
		-- and ((att:IsControler(tp) and att:IsRace(RACE_FAIRY))
		-- or (def:IsControler(tp) and def:IsRace(RACE_FAIRY)))
-- end
-- function c16599454.register(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	-- e1:SetCode(EVENT_PREDRAW)
	-- e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	-- e1:SetCountLimit(1)
	-- e1:SetOperation(c16599454.regflag)
	-- e1:SetReset(RESET_EVENT+EVENT_CUSTOM+16599454)
	-- c:RegisterEffect(e1)
-- end
-- function c16599454.regflag(e)
	-- local c=e:GetHandler()
	-- local tp=c:GetControler()
	-- c:RegisterFlagEffect(16599454,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
	-- Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+16599454,e,0,tp,tp,0)
	-- Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+16599454,e,0,tp,tp,0)
-- end
-- function c16599454.regop(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- --inflict damage
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetDescription(aux.Stringid(16599454,0))
	-- e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
	-- e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e1:SetCode(EVENT_PHASE+PHASE_END)
	-- e1:SetRange(LOCATION_MZONE)
	-- e1:SetCountLimit(1,16599454+EFFECT_COUNT_CODE_DUEL)
	-- e1:SetCondition(c16599454.damcon)
	-- e1:SetTarget(c16599454.damtg)
	-- e1:SetOperation(c16599454.damop)
	-- e1:SetReset(RESET_EVENT+0x1fc0000+RESET_PHASE+PHASE_END)
	-- c:RegisterEffect(e1)
-- end
-------------------------------------------------
--filters
function c16599454.costfilter(c,tp)
	return c:IsSetCard(0x1559) and c:GetLevel()>0 and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE)))
		and Duel.IsExistingTarget(c16599454.lvfilter,tp,LOCATION_MZONE,0,1,nil,c:GetOriginalLevel())
end
function c16599454.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
function c16599454.chgfilter(c,tp)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:GetLevel()>0
		and not Duel.IsExistingMatchingCard(c16599454.lvcheck,tp,0,LOCATION_MZONE,1,c,c:GetLevel())
end
function c16599454.lvcheck(c,lv)
	return c:IsFaceup() and c:GetLevel()<lv and c:GetLevel()>0
end
function c16599454.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1559) and re:GetHandler():GetLevel()==e:GetHandler():GetLevel() and not re:GetHandler():IsType(TYPE_SYNCHRO)
		and not re:GetHandler():IsCode(16599454)
end
--target protection
function c16599454.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(11)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=11)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--avoid battle damage
function c16599454.bfilter(e,c)
	return c:IsRace(RACE_FAIRY)
end
--change levels
function c16599454.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c16599454.lvfilter(c,lv)
	return c:IsFaceup() and c:GetLevel()~=lv
end
function c16599454.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc~=c and c16599454.lvfilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c16599454.costfilter,tp,LOCATION_MZONE+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599454.costfilter,tp,LOCATION_MZONE+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		local op=Duel.GetOperatedGroup():GetFirst()
		if op then
			e:SetLabel(op:GetOriginalLevel())
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			Duel.SelectTarget(tp,c16599454.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabel())
		end
	end
end
function c16599454.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
--inflict damage
-- function c16599454.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- return e:GetHandler():GetFlagEffect(16599454)>0 or e:GetHandler():GetFlagEffect(26599454)>0
-- end
-- function c16599454.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- Duel.SetTargetPlayer(1-tp)
	-- Duel.SetTargetParam(2000)
	-- Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
	-- Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
-- end
-- function c16599454.damop(e,tp,eg,ep,ev,re,r,rp)
	-- local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- Duel.Damage(p,d,REASON_EFFECT)
	-- Duel.BreakEffect()
	-- Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_EFFECT)
-- end
--change control
function c16599454.chgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
function c16599454.chgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c16599454.chgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c16599454.chgfilter,tp,0,LOCATION_MZONE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,c16599454.chgfilter,tp,0,LOCATION_MZONE,1,1,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c16599454.chgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
		if tc:IsControler(tp) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(RACE_FAIRY)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
		end
	end
	--activation limit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c16599454.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end