--[[
Number C201: Sceluspecter Phantasm Magician
Numero C201: Scelleraspettro Fantasma Mago
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--4 DARK monsters with the same Level
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,4,4)
	--Check Materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: Your opponent must send as many face-up cards they control as possible to the GY.
	If this card was Xyz Summoned using "Number 201: Phantom Magician" as material, your opponent cannot activate cards or effects in response to this effect's activation,
	also your opponent must attach those cards to this card as materials, instead of sending them to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
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
	--[[(Quick Effect): You can detach up to 3 materials from this card; your opponent must banish that many random cards from their Extra Deck, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		aux.DummyCost,
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e2)
	--[[This card gains the original effects of all "Number" monsters attached to it as material, except those of monsters whose original name is "Number 201: Sceluspecter Phantom Magician".]]
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
	return c:IsFaceup() and c:IsXyzType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK)
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
	if g and g:IsExists(Card.IsCode,1,nil,CARD_NUMBER_201) then
		c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end

--E1
function s.tdfilter(c,p,matcheck)
	return c:IsFaceup() and (not matcheck and Duel.IsPlayerCanSendtoGrave(1-p,c) or (matcheck and c:IsCanOverlay(p)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local matcheck=c:IsXyzSummoned() and c:IsType(TYPE_XYZ) and c:HasFlagEffect(id+100)
	if chk==0 then
		return Duel.IsExists(false,s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil,tp,matcheck)
	end
	if matcheck then
		Duel.SetChainLimit(s.chlimit)
		e:SetCategory(0)
		Duel.SetTargetParam(1)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetTargetParam(0)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local matcheck=Duel.GetTargetParam()==1
	local g=Duel.Group(s.tdfilter,tp,0,LOCATION_ONFIELD,nil,tp,matcheck)
	if #g>0 then
		if matcheck then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
				Duel.Attach(g,c,false,nil,REASON_RULE,1-tp)
			end
		else
			Duel.SendtoGrave(g,REASON_RULE,1-tp)
		end
	end
end

--E2
function s.rmfilter(c,p)
	return c:IsAbleToRemove(p,POS_FACEDOWN,REASON_RULE)
end
function s.rmcheck(g,c)
	return	function(n,p)
				return #g>=n and c:CheckRemoveOverlayCard(tp,n,REASON_COST)
			end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_EXTRA,nil,1-tp)
	if chk==0 then
		return #g>0 and e:IsCostChecked() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	local n=Duel.AnnounceNumberMinMax(tp,1,3,s.rmcheck(g,c))
	c:RemoveOverlayCard(tp,n,n,REASON_COST)
	Duel.SetTargetParam(n)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_EXTRA,nil,1-tp)
	if #g<ct then return end
	local rg=g:RandomSelect(1-tp,ct)
	Duel.Remove(rg,POS_FACEDOWN,REASON_RULE,1-tp)
end

--E3
function s.validfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_NUMBER) and not c:IsOriginalCodeRule(id)
end
function s.copyfilter(c)
	return s.validfilter(c) and not c:HasFlagEffect(id)
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup():Filter(s.copyfilter,nil)
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