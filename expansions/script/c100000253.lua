--[[
Automatyrant Subspace Gears Dragon
Automatiranno Drago Subspaziale di Ingranaggi
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,3)
	--For this card's Link Summon, you can also use Union Monster Cards you control in your Spell & Trap Zone as materials.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_SZONE,0)
	e0:SetValue(s.matval)
	c:RegisterEffect(e0)
	--[[If this card is Link Summoned: You can shuffle as many cards from the GYs into the Decks as possible, and if you do,
	this card gains 100 ATK for each monster shuffled into the Deck with different original names this way.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can destroy 1 Equip Card you control; banish 1 card your opponent controls, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.DestroyCost(Card.IsEquipCard,LOCATION_SZONE),
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e2)
	--[[This card gains 1 additional attack on monsters during each Battle Phase for each card equipped to this card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end
s.has_text_type=TYPE_UNION

--E0
function s.matfilter(c)
	return c:IsLinkRace(RACE_MACHINE) or s.exmatfilter(c,self_reference_effect:GetHandlerPlayer())
end
function s.exmatfilter(c,tp)
	return c:IsInBackrow() and c:IsControler(tp) and c:IsOriginalType(TYPE_UNION)
end
function s.exmatcheck(c,lc,tp)
	if not s.exmatfilter(c,tp) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in ipairs(le) do
		local f=te:GetValue()
		local related,valid=f(te,lc,nil,c,tp)
		if related and te:GetOwner():IsOriginalCode(id) then
			return false
		end
	end
	return true	  
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return c:IsOriginalType(TYPE_UNION), not mg or not mg:IsExists(s.exmatcheck,1,nil,lc,tp)
end

--E1
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,PLAYER_ALL,LOCATION_GRAVE)
	local c=e:GetHandler()
	local ct=g:Filter(Card.IsMonster,nil):GetClassCount(Card.GetOriginalCodeRule)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),ct*100)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 then
		local mg=g:Filter(Card.IsMonster,nil)
		for tc in aux.Next(mg) do
			local codes={tc:GetOriginalCodeRule()}
			for _,code in ipairs(codes) do
				tc:RegisterFlagEffect(id,RESET_PHASE|PHASE_END|RESET_CHAIN,0,1,code)
			end
		end
		if Duel.ShuffleIntoDeck(g)>0 then
			local ct=Duel.GetGroupOperatedByThisEffect(e):Filter(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA):GetClassCount(Card.GetFlagEffectLabel,id)
			if ct>0 then
				local c=e:GetHandler()
				if c:IsRelateToChain() and c:IsFaceup() then
					c:UpdateATK(ct*100,true,c)
				end
			end
		end
	end
end

--E2
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,1,nil,tp)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

--E3
function s.atkval(e,c)
	return e:GetHandler():GetEquipCount()
end