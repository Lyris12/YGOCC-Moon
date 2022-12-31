--Quartus dell'Organizzazione Angeli, Liber
--Script by XGlitchy30
function c16599466.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599466.efilter)
	c:RegisterEffect(e0)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c16599466.drawcon)
	e1:SetCost(c16599466.drawcost)
	e1:SetTarget(c16599466.drawtg)
	e1:SetOperation(c16599466.drawop)
	c:RegisterEffect(e1)
	--gain atk
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetCategory(CATEGORY_ATKCHANGE)
	-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	-- e2:SetCode(EVENT_BATTLE_DAMAGE)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetCondition(c16599466.atkcon)
	-- e2:SetTarget(c16599466.atktg)
	-- e2:SetOperation(c16599466.atkop)
	-- c:RegisterEffect(e2)
	--recover resources
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,16599466)
	e3:SetCondition(c16599466.sccon)
	e3:SetCost(c16599466.sccost)
	e3:SetTarget(c16599466.sctg)
	e3:SetOperation(c16599466.scop)
	c:RegisterEffect(e3)
end
--filters
function c16599466.mfilter(c,sync)
	return c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsAbleToRemoveAsCost()
end
function c16599466.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetAttack()==0
end
function c16599466.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end
function c16599466.thfilter(c)
	return c:IsSetCard(0x1559) and c:IsAbleToHand()
end
--target protection
function c16599466.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(8)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=8)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--draw
function c16599466.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c16599466.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local matc=mat:GetCount()
	if chk==0 then return matc>0 and mat:FilterCount(c16599466.mfilter,nil,c)==matc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=mat:Select(tp,matc,matc,nil)
	if g:GetCount()==matc then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599466.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c16599466.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--gain atk
-- function c16599466.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- local att=Duel.GetAttacker()
	-- local def=Duel.GetAttackTarget()
	-- return ep==tp and att and def
		-- and ((att:GetControler()==tp and att:IsRace(RACE_FAIRY) and att:IsRelateToBattle())
		-- or (def:GetControler()==tp and def:IsRace(RACE_FAIRY) and def:IsRelateToBattle()))
-- end
-- function c16599466.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16599466.atkfilter(chkc) end
	-- if chk==0 then return Duel.IsExistingTarget(c16599466.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- Duel.SelectTarget(tp,c16599466.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
-- end
-- function c16599466.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- local tc=Duel.GetFirstTarget()
	-- if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- local e1=Effect.CreateEffect(e:GetHandler())
		-- e1:SetType(EFFECT_TYPE_SINGLE)
		-- e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- e1:SetValue(ev)
		-- e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		-- tc:RegisterEffect(e1)
	-- end
-- end
--recover resources
function c16599466.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and re:GetHandler():IsType(TYPE_SYNCHRO)
end
function c16599466.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599466.costfilter,tp,LOCATION_DECK,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599466.costfilter,tp,LOCATION_DECK,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599466.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c16599466.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16599466.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c16599466.thfilter,tp,LOCATION_REMOVED,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c16599466.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end