--[[
Number i214: Manaseal Lorekeeper
Numero i214: Custode della Tradizione Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	c:EnableReviveLimit()
	--3+ Level 9 monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),5,2,nil,nil,99)
	--[[If this card is Xyz Summoned, or when a Trap Card or effect is activated while you control this monster (Quick Effect): You can target 1 Spell in your opponent's GY or banishment; attach it
	to this card as material.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCustomCategory(CATEGORY_ATTACH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	--[[Once per turn: You can detach 1 material from this card; add 1 "Manaseal" card or "Rank-Up-Magic" Spell from your Deck or GY to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetFunctions(
		nil,
		aux.DetachSelfCost(),
		xgl.SearchTarget(s.thfilter,LOCATION_DECK|LOCATION_GRAVE),
		xgl.SearchOperation(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	)
	c:RegisterEffect(e3)
	--[[While you control a face-up "Manaseal Rune Weaving", your opponent cannot target "Manaseal" cards on the field with Spell Cards or effects with the same original name as a Spell(s) attached to
	this card.]]
	c:CannotBeTargetedByEffectsField(s.tgval,LOCATION_MZONE,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.Filter(Card.IsSetCard,ARCHE_MANASEAL),
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING)))
end
aux.xyz_number[id]=207

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP)
end
function s.atfilter(c,e,tp,h)
	return c:IsFaceupEx() and c:IsSpell() and c:IsCanBeAttachedTo(h,e,tp,REASON_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(1-tp) and s.atfilter(chkc,e,tp,c) end
	if chk==0 then return Duel.IsExists(true,s.atfilter,tp,0,LOCATION_GB,1,nil,e,tp,c) end
	local g=Duel.Select(HINTMSG_ATTACH,true,tp,s.atfilter,tp,0,LOCATION_GB,1,1,nil,e,tp,c)
	if g:GetFirst():IsInGY() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,0)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,#g,0,0,h)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) and tc:IsRelateToChain() then
		Duel.Attach(tc,c,false,e,REASON_EFFECT,tp)
	end
end

--E3
function s.thfilter(c)
	return c:IsSetCard(ARCHE_MANASEAL) or (c:IsSpell() and c:IsSetCard(ARCHE_RUM))
end

--E4
function s.tgval(e,re)
	local c=e:GetHandler()
	if not c:IsType(TYPE_XYZ) or not re:IsActiveType(TYPE_SPELL) then return false end
	local g=c:GetOverlayGroup():Filter(Card.IsSpell,nil)
	return g:IsExists(Card.IsOriginalCodeRule,1,nil,re:GetHandler():GetOriginalCodeRule())
end