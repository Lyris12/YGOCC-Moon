--[[
Number iC214: Manaseal Chronicler
Numero iC214: Cronista Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	c:EnableReviveLimit()
	--3+ Level 9 monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),6,3,nil,nil,99)
	--Must first be Special Summoned with a "Rank-Up-Magic" Spell targeting "Number i214: Manaseal Lorekeeper".
	if not s.rum_limit then
		s.rum_limit=aux.CreateRUMLimitFunction(s.rumlimit)
	end
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned, or when a Trap Card or effect is activated while you control this monster (in which case this is a Quick Effect): You can target a number of Spells in your
	opponent's GY or banishment, up to the number of Trap Cards and effects that were activated previously this turn; attach those targets to this card as materials.]]
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
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.counterfilter)
	--[[You can detach up to 3 materials from this card; add an equal number of "Manaseal" cards and/or "Rank-Up-Magic" Spells from your Deck, GY, and/or banishment to your hand, but if you do, you
	cannot add cards to your hand for the rest of this turn after this effect resolves, except by drawing them.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		aux.DummyCost(),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e3)
	--[[While you control "Manaseal Rune Weaving", your opponent cannot apply or activate Spell Cards or effects with the same original name as a Spell Card attached to this card as a
	material.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING)))
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_APPLY)
	e5:SetValue(s.aclimit2)
	c:RegisterEffect(e5)
end
aux.xyz_number[id]=207

function s.rumlimit(mc,e,tp,c)
	return mc:IsCode(id-1)
end
function s.counterfilter(e,tp,cid)
	return not e:IsActiveType(TYPE_TRAP)
end

--E0
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(ARCHE_RUM) and se:GetHandler():IsType(TYPE_SPELL)
		and se:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

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
	local ct=Duel.GetCustomActivityCount(id,0,ACTIVITY_CHAIN)+Duel.GetCustomActivityCount(id,1,ACTIVITY_CHAIN)
	if chk==0 then return ct>0 and Duel.IsExists(true,s.atfilter,tp,0,LOCATION_GB,1,nil,e,tp,c) end
	local g=Duel.Select(HINTMSG_ATTACH,true,tp,s.atfilter,tp,0,LOCATION_GB,1,ct,nil,e,tp,c)
	local tg=g:Filter(Card.IsInGY,nil)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,#tg,1-tp,0)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,#g,0,0,h)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(Card.IsSpell,nil):Filter(Card.IsControler,nil,1-tp)
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) and #g>0 then
		Duel.Attach(g,c,false,e,REASON_EFFECT,tp)
	end
end

--E3
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsAbleToHand() and (c:IsSetCard(ARCHE_MANASEAL) or (c:IsSpell() and c:IsSetCard(ARCHE_RUM)))
end
function s.rmcheck(g,c)
	return	function(n,p)
				return #g>=n and c:CheckRemoveOverlayCard(tp,n,REASON_COST)
			end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.thfilter,tp,LOCATION_DECK|LOCATION_GB,0,nil)
	if chk==0 then
		return e:IsCostChecked() and #g>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	local n=Duel.AnnounceNumberMinMax(tp,1,3,s.rmcheck(g,c))
	c:RemoveOverlayCard(tp,n,n,REASON_COST)
	Duel.SetTargetParam(n)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,n,tp,LOCATION_DECK|LOCATION_GB)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	local g=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GB,0,nil)
	if #g<ct then return end
	Duel.HintMessage(tp,HINTMSG_ATOHAND)
	local tg=g:Select(tp,ct,ct,nil)
	if Duel.SearchAndCheck(tg) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,2)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TO_HAND)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--E4
function s.aclimit(e,re,tp)
	local c=e:GetHandler()
	if not c:IsType(TYPE_XYZ) or not re:IsActiveType(TYPE_SPELL) then return false end
	local g=c:GetOverlayGroup():Filter(Card.IsSpell,nil)
	return g:IsExists(Card.IsOriginalCodeRule,1,nil,re:GetHandler():GetOriginalCodeRule())
end
function s.aclimit2(e,re,tp,rc)
	local c=e:GetHandler()
	if not c:IsType(TYPE_XYZ) or not rc:IsSpell() then return false end
	local g=c:GetOverlayGroup():Filter(Card.IsSpell,nil)
	return g:IsExists(Card.IsOriginalCodeRule,1,nil,rc:GetOriginalCodeRule())
end