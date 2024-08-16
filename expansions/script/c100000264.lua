--[[
Sceluspecter Cursed Phantom
Scelleraspettro Spirito Maledetto
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
	--[[If this card is banished: You can send 1 "Sceluspecter" monster from your Deck to the GY; add 1 "Rank-Up-Magic" Spell from your Deck or GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.ToGraveCost(aux.MonsterFilter(Card.IsSetCard,ARCHE_SCELUSCEPTER),LOCATION_DECK),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	--[[While this card is equipped to a monster, that monster becomes a DARK Fiend monster, also its ATK/DEF become 0.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetValue(0)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_DEFENSE)
	e4:SetValue(0)
	c:RegisterEffect(e4)
end

--E2
function s.filter(c)
	return c:IsSetCard(ARCHE_RUM) and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end