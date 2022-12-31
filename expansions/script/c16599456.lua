--Agens dell'Organizzazione Angeli, Siguas
--Script by XGlitchy30
function c16599456.initial_effect(c)
	--battle protection
	-- local e1x=Effect.CreateEffect(c)
	-- e1x:SetType(EFFECT_TYPE_SINGLE)
	-- e1x:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- e1x:SetCondition(c16599456.battleprotection)
	-- e1x:SetValue(1)
	-- c:RegisterEffect(e1x)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599456.efilter)
	c:RegisterEffect(e0)
	--act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c16599456.limcon)
	e1:SetValue(c16599456.limval)
	c:RegisterEffect(e1)
	--spsummon
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e2:SetCode(EVENT_PHASE+PHASE_END)
	-- e2:SetRange(LOCATION_REMOVED)
	-- e2:SetCountLimit(1)
	-- e2:SetLabel(0)
	-- e2:SetCondition(c16599456.spcon)
	-- e2:SetTarget(c16599456.sptg)
	-- e2:SetOperation(c16599456.spop)
	-- c:RegisterEffect(e2)
	--add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(c16599456.thcon)
	e3:SetTarget(c16599456.thtg)
	e3:SetOperation(c16599456.thop)
	c:RegisterEffect(e3)
	--Register Damage
	-- local ge0=Effect.CreateEffect(c)
	-- ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- ge0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	-- ge0:SetCode(EVENT_DAMAGE)
	-- ge0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	-- ge0:SetLabelObject(e2)
	-- ge0:SetCondition(c16599456.regcon)
	-- ge0:SetOperation(c16599456.register)
	-- c:RegisterEffect(ge0)
	-- --Reset Damage
	-- local ge1=Effect.CreateEffect(c)
	-- ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	-- ge1:SetCode(EVENT_TURN_END)
	-- ge1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	-- ge1:SetCountLimit(1)
	-- ge1:SetLabelObject(e2)
	-- ge1:SetCondition(c16599456.resetcon)
	-- ge1:SetOperation(c16599456.reset)
	-- c:RegisterEffect(ge1)
end
-----Register Damage-----
-- function c16599456.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- local att=Duel.GetAttacker()
	-- local def=Duel.GetAttackTarget()
	-- return att and def and ep==tp and bit.band(r,REASON_BATTLE)~=0
		-- and ((att:IsControler(tp) and att:IsRace(RACE_FAIRY))
		-- or (def:IsControler(tp) and def:IsRace(RACE_FAIRY)))
-- end
-- function c16599456.register(e,tp,eg,ep,ev,re,r,rp)
	-- local att=Duel.GetAttacker()
	-- local def=Duel.GetAttackTarget()
	-- local base=e:GetLabelObject():GetLabel()
	-- e:GetLabelObject():SetLabel(base+ev)
	-- if att:IsControler(tp) and att:IsRace(RACE_FAIRY) then
		-- att:RegisterFlagEffect(16599456,RESET_PHASE+PHASE_DRAW,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
	-- elseif def:IsControler(tp) and def:IsRace(RACE_FAIRY) then
		-- def:RegisterFlagEffect(16599456,RESET_PHASE+PHASE_DRAW,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
	-- else
		-- return
	-- end
-- end
-- -----Reset Damage-----
-- function c16599456.resetcon(e,tp,eg,ep,ev,re,r,rp)
	-- return e:GetLabelObject():GetLabel()>0
-- end
-- function c16599456.reset(e,tp,eg,ep,ev,re,r,rp)
	-- e:GetLabelObject():SetLabel(0)
-- end
-------------------------
--filters
function c16599456.limfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsFacedown() or not c:IsRace(RACE_FAIRY))
end
function c16599456.battled(c)
	return c:GetFlagEffect(16599456)>0 and c:IsAbleToRemove()
end
function c16599456.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1559) and re:GetHandler():GetLevel()==e:GetHandler():GetLevel() and not re:GetHandler():IsType(TYPE_SYNCHRO)
		and not re:GetHandler():IsCode(16599456)
end
function c16599456.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
--battle protection
function c16599456.battleprotection(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
--target protection
function c16599456.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(9)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=9)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--act limit
function c16599456.limcon(e)
	return not Duel.IsExistingMatchingCard(c16599456.limfilter,e:GetHandler():GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c16599456.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and not rc:IsImmuneToEffect(e)
		and bit.band(rc:GetSummonLocation(),LOCATION_DECK+LOCATION_EXTRA)>0
end
--spsummon
-- function c16599456.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- return e:GetLabel()>=2800
-- end
-- function c16599456.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- local c=e:GetHandler()
	-- if chk==0 then return c:IsLocation(LOCATION_REMOVED) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- and Duel.IsExistingMatchingCard(c16599456.battled,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,nil)
		-- and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- end
	-- Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE)
-- end
-- function c16599456.spop(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- if c:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
		-- if not Duel.IsExistingMatchingCard(c16599456.battled,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,nil) then return end
		-- if Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)~=0 then
			-- local g=Duel.GetMatchingGroup(c16599456.battled,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
			-- if g:GetCount()>0 then
				-- Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			-- end
		-- end
	-- end
	-- --reset flags
	-- local res=Duel.GetMatchingGroup(c16599456.battled,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA,nil)
	-- if res:GetCount()<=0 then return end
	-- for i in aux.Next(res) do
		-- i:ResetFlagEffect(16599456)
	-- end
-- end
--add to hand
function c16599456.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
function c16599456.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c16599456.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16599456.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c16599456.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c16599456.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
	--activation limit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c16599456.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end