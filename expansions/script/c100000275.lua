--[[
Number 201: Sceluspecter Phantom Magician
Numero 201: Scelleraspettro Spirito Mago
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3 monsters with the same Level
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,3,3)
	--Check materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can activate this effect; your opponent must shuffle 4 cards they control into the Deck.
	If you used Level 7 or higher monsters as materials to Xyz Summon this card, your opponent cannot activate cards or effects in response to this effect's activation.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can detach 1 material from this card; for the rest of this turn, the effects of all face-up monsters your opponent currently controls are negated.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		aux.DetachSelfCost(),
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
	--[[This card gains the effects of all other monsters on the field whose effects are negated, except those of monsters whose original name is "Number 201: Sceluspecter Phantom Magician".]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.adjustop)
	e3:SetLabel(id)
	c:RegisterEffect(e3)
end
aux.xyz_number[id]=201

function s.mfilter(c,xyzc)
	return c:IsFaceup() and c:IsXyzType(TYPE_MONSTER)
end
function s.xyzcheck(g,tp,xyzc)
	local og=g:Clone()
	local tc=og:GetFirst()
	og:RemoveCard(tc)
	local lvcounter={}
	local levels={tc:GetXyzLevel(xyzc)}
	for tc2 in aux.Next(og) do
		local levels2={tc2:GetXyzLevel(xyzc)}
		for _,lv2 in ipairs(levels2) do
			for _,lv in ipairs(levels) do
				if lv==lv2 then
					if not lvcounter[lv] then
						lvcounter[lv]=1
					end
					lvcounter[lv]=lvcounter[lv]+1
				end
			end
		end
	end	
	for _,count in pairs(lvcounter) do
		if count==#g then
			return true
		end
	end
	return false
end

--E0
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g then
		local check=false
		for tc in aux.Next(g) do
			local levels={tc:GetXyzLevel(c)}
			for _,lv in ipairs(levels) do
				if lv>=7 then
					check=true
					break
				end
			end
			if check then
				break
			end
		end
		if check then
			c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		end
	end
end

--E1
function s.tdfilter(c,p)
	return Duel.IsPlayerCanSendtoDeck(p,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tdfilter,tp,0,LOCATION_ONFIELD,4,nil,1-tp) end
	local c=e:GetHandler()
	if c:IsXyzSummoned() and c:HasFlagEffect(id+100) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TODECK,false,1-tp,s.tdfilter,tp,0,LOCATION_ONFIELD,4,4,nil,1-tp)
	if #g==4 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE,1-tp)
	end
end

--E2
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if #g>0 then
		Duel.Negate(g,e,RESET_PHASE|PHASE_END,false,false,TYPE_MONSTER)
	end
end

--E3
function s.validfilter(c)
	return c:IsFaceup() and c:IsDisabled() and not c:IsOriginalCodeRule(id)
end
function s.copyfilter(c)
	return s.validfilter(c) and not c:HasFlagEffect(id)
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.copyfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabel(cid)
		e1:SetLabelObject(tc)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local tc=e:GetLabelObject()
	if not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or not tc:HasFlagEffect(id) or not s.validfilter(tc) then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		tc:ResetFlagEffect(id)
		e:Reset()
	end
end