--[[
Voidictator Rune - Court of the Void
Runa dei Vuotodespoti - Corte del Vuoto
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: You can add 2 "Voidictator" cards (including a Ritual Monster) from your Deck and/or GY to your hand, except "Voidictator Rune - Court of the Void".]]
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:HOPT(true)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--[[Your opponent cannot apply or activate the effects of monsters with the same card type (Ritual, Fusion, Synchro, Xyz, Pendulum, Pandemonium, Link, Bigbang, Spatial, Time Leap, Drive, Perdition) as "Voidictator Deity" and "Voidictator Demon" monsters you control.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_APPLY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.limcon)
	e2:SetValue(s.applim)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2x:SetValue(s.actlim)
	c:RegisterEffect(e2x)
	--[[If this card is banished because of a "Voidictator" card you own: You can banish 1 "Voidictator" card from your hand or GY; Set this card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:HOPT()
	e3:SetCondition(s.setcon)
	e3:SetCost(aux.BanishCost(aux.ArchetypeFilter(ARCHE_VOIDICTATOR),LOCATION_HAND|LOCATION_GRAVE))
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

local TYPES = TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK|TYPE_PANDEMONIUM|TYPE_BIGBANG|TYPE_SPATIAL|TYPE_TIMELEAP|TYPE_DRIVE

--E1
function s.thfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.gcheck(g,e,tp,mg,c)
	return g:IsExists(Card.IsMonster,1,nil,TYPE_RITUAL), not mg:IsExists(Card.IsMonster,1,nil,TYPE_RITUAL)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0) and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_ATOHAND,nil,nil,false)
		if #sg==2 then
			Duel.Search(sg,tp)
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON) and c:IsType(TYPES)
end
function s.limcon(e)
	return Duel.IsExists(false,s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.applim(e,re,rp,rc)
	if not rc or rc:IsLocation(LOCATION_SZONE) or (not rc:IsType(TYPE_MONSTER) and not rc:IsLocation(LOCATION_MZONE)) then return false end
	local g=Duel.Group(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local typ=0
	for tc in aux.Next(g) do
		local ltyp=tc:GetType()&TYPES
		typ=typ|ltyp
	end
	return rc:IsType(typ)
end
function s.actlim(e,re,rp)
	local rc=re:GetHandler()
	if not rc or not re:IsActiveType(TYPE_MONSTER) then return false end
	local g=Duel.Group(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local typ=0
	for tc in aux.Next(g) do
		local ltyp=tc:GetType()&TYPES
		typ=typ|ltyp
	end
	return re:IsActiveType(typ)
end

--E3
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end