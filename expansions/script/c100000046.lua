--created by Swag, coded by XGlitchy30
--Fay'lah, Cradle of the Dreary Forest
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDoubleSidedType(c)
	aux.AddDoubleSidedProc(c,SIDE_REVERSE,id-1,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TRANSFORMED)
	e1:HOPT()
	e1:SetCondition(aux.PreTransformationCheckSuccessSingle)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	aux.AddPreTransformationCheck(c,e1,id-1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.condition)
	e2:SetTarget(aux.nbtg)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	aux.AddDreamyDrearyTransformation(c,ARCHE_DREAMY_FOREST)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local rct = Duel.GetTurnPlayer()==tp and 1 or 2
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_IGNORE_BATTLE_TARGET)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_TURN_OPPO,rct)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:Desc(3)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(s.immval)
		c:RegisterEffect(e2)
	end
end
function s.immval(e,te)
	if te:GetOwnerPlayer()~=1-e:GetHandlerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
