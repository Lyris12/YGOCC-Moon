--[[
Sceluspecter Mirror Phantom
Scelleraspettro Spirito dello Specchio
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
	--[[If this card is banished: You can discard 1 "Sceluspecter" monster; add 1 "Sceluspecter" card from your Deck to your hand, except "Sceluspecter Mirror Phantom".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.DiscardCost(aux.MonsterFilter(Card.IsSetCard,ARCHE_SCELUSPECTER)),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	--[[While this card is equipped to a monster, that monster becomes a DARK Fiend monster, also your opponent takes any battle damage you would have taken from battles involving that monster]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.rfcon)
	c:RegisterEffect(e5)
end

--E2
function s.filter(c)
	return c:IsSetCard(ARCHE_SCELUSPECTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E3
function s.rfcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (Duel.GetAttacker()==ec or Duel.GetAttackTarget()==ec)
end