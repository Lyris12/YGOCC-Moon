--[[
Number C207: Manaseal Avatar
Numero C207: Avatar Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3+ Level 9 monsters
	aux.AddXyzProcedure(c,nil,9,3,nil,nil,99)
	--Must be Special Summoned with a "Rank-Up-Magic" Spell targeting "Number 207: Manaseal Archon".
	if not s.rum_limit then
		s.rum_limit=aux.CreateRUMLimitFunction(s.rumlimit)
	end
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--Unaffected by Spell effects.
	c:Unaffected(UNAFFECTED_SPELL)
	--[[If this card is Xyz Summoned, or when a Spell Card or effect is activated (in which case this is a Quick Effect): You can send 2 Normal Traps from your hand and/or Deck to the GY with
	different original names, and if you do, banish all Spells on the field and in the GYs face-down, except "Rank-Up-Magic" and "Manaseal" Spells.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	--[[At the start of the Standby Phase (Quick Effect): You can declare 1 Spell Card name; the next time your opponent resolves an activated Spell Card or effect with the same original name as the
	declared one, that activated effect becomes the following effect.
	● Banish this card and as many cards with the same original name as this card from your hand, field, GY, and Deck as possible, face-down, then your opponent can add 1 DARK monster from their Deck
	or GY to their hand. ]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE_START|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetCondition(aux.StandbyPhaseCond())
	e3:SetOperation(s.raise)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		s.regcon,
		nil,
		s.regtg,
		s.regop
	)
	c:RegisterEffect(e4)
end
aux.xyz_number[id]=207

function s.rumlimit(mc,e,tp,c)
	return mc:IsCode(id-1)
end

--E0
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(ARCHE_RUM) and se:GetHandler():IsType(TYPE_SPELL)
		and se:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL)
end
function s.tgfilter(c)
	return c:IsNormalTrap() and c:IsAbleToGrave()
end
function s.rmfilter(c,tp)
	return c:IsFaceupEx() and c:IsSpell() and not c:IsSetCard(ARCHE_RUM,ARCHE_MANASEAL,true) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	local g=Duel.Group(s.rmfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil,tp)
	if chk==0 then return tg:GetClassCount(Card.GetOriginalCodeRule)>=2 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg0=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	local tg=aux.SelectUnselectGroup(tg0,e,tp,2,2,aux.ogdncheckbrk,1,tp,HINTMSG_TOGRAVE)
	if #tg==2 and Duel.SendtoGraveAndCheck(tg,nil,REASON_EFFECT,2) then
		local g=Duel.Group(aux.Necro(s.rmfilter),tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil,tp)
		if #g>0 then
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

--E2
function s.raise(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
end

--E3
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:GetFirst()==e:GetHandler() and not Duel.CheckPhaseActivity()
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	getmetatable(e:GetHandler()).announce_filter={TYPE_SPELL,OPCODE_ISTYPE}
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=Duel.GetTargetParam()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:OPT()
	e1:SetLabel(ac)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	Duel.RegisterEffect(e1,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsOriginalCodeRule(e:GetLabel())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
	e:Reset()
end
function s.rmfilter2(c,tp,...)
	return c:IsFaceupEx() and c:IsOriginalCodeRule(...) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(aux.Necro(s.rmfilter2),tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,tp,c:GetOriginalCodeRule())
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 and Duel.IsExists(false,aux.Necro(s.thfilter),tp,0,LOCATION_DECK|LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(1-tp,STRING_ASK_SEARCH) then
		local tg=Duel.Select(HINTMSG_ATOHAND,false,1-tp,aux.Necro(s.thfilter),tp,0,LOCATION_DECK|LOCATION_GRAVE,1,1,nil)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.Search(tg)
		end
	end
end