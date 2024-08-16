--[[
Sceluspecter Occult Phantom
Scelleraspettro Spirito dell'Occulto
Card Author: Walrus
Scripted by: XGlitchy30
]]

if not GLITCHYLIB_YGOCC_ARCHETYPES_LOADED then
	Duel.LoadScript("glitchylib_ygocc_archetypes.lua")
end

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main Phase, if this card is in your hand (Quick Effect): You can banish 1 "Sceluspecter" monster from your GY; equip this card to 1 monster your opponent controls.]]
	YGOCC.RegisterSceluspecterEquip(c,id)
	--[[If this card is banished: You can return 2 other banished cards to your GY; Set 1 "Sceluspecter" Trap from your Deck to your hand. It can be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		s.setcost,
		s.settg,
		s.setop
	)
	c:RegisterEffect(e2)
	--[[While this card is equipped to a monster, that monster becomes a DARK Fiend monster, also it cannot activate its effects in response to your card or effect activations.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(aux.IsEquippedCond)
	e3:SetOperation(s.chainop)
	c:RegisterEffect(e3)
end

--E2
function s.cfilter(c,e)
	return c:IsAbleToReturnToGraveAsCost(e)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,2,c,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED,0,2,2,c,e)
	Duel.HintSelection(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_RETURN)
end
function s.setfilter(c)
	return c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSetAndFastActivation(tp,g,e)
	end
end

--E3
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		Duel.SetChainLimit(s.chainlm(e))
	end
end
function s.chainlm(e)
	return	function(re,ep,tp)
				local ec=e:GetHandler():GetEquipTarget()
				return ep==tp or re:GetHandler()~=ec
			end
end