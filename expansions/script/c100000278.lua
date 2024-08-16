--[[
Number iC208: Sceluspecter Phantasm Hands
Numero iC208: Scelleraspettro Mani Fantasma
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3 Level 3 DARK monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,3)
	--Check Materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: Send 3 "Sceluspecter" cards from your Deck to the GY, then, if this card was Xyz Summoned using "Number i208: Sceluspecter Phantom Hands" as material,
	your opponent loses 400 LP for each material attached to this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can detach any number of materials from this card, then target that same number of monsters your opponent controls;
	equip 1 "Sceluspecter" monster from your hand, Deck, and/or GY to each of those targets.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		aux.DummyCost,
		s.eqtg,
		s.eqop
	)
	c:RegisterEffect(e2)
end
aux.xyz_number[id]=208

--E0
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g and g:IsExists(Card.IsCode,1,nil,CARD_NUMBER_I208) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end

--E1
function s.tgfilter(c)
	return c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local c=e:GetHandler()
	if c:IsXyzSummoned() and c:HasFlagEffect(id) then
		Duel.SetTargetParam(1)
	else
		Duel.SetTargetParam(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,3,nil) then return end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,3,3,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)==3 and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==3 and Duel.GetTargetParam()==1 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
			local ct=c:GetOverlayCount()
			if ct>0 then
				Duel.LoseLP(1-tp,ct*400)
			end
		end
	end
end

--E2
function s.eqtofilter_base(c,e,tp)
	return c:IsCanBeEquippedWith(nil,e,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.eqtofilter(c,e,tp)
	return Duel.IsExists(false,s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,c,c,e,tp)
end
function s.eqfilter_base(c,ec,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.eqfilter(c,ec,e,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and ec:IsCanBeEquippedWith(c,e,tp,REASON_EFFECT)
end
function s.eqfilter_res(c,ec,e,tp,ft,g,eqg,gtocheck,eqgtocheck)
	return s.eqfilter(c,ec,e,tp) and s.TryFindingValidEquipper(c,ec,e,nil,ft,g,eqg,gtocheck,eqgtocheck)
end
function s.eqfilter_alt(c,e,tp)
	local loc=c:DestinationRedirect(LOCATION_GRAVE,REASON_COST)
	if loc==0 then
		loc=LOCATION_GRAVE
	end
	if loc&(0|LOCATION_DECK|LOCATION_GRAVE)==0 or not c:IsAbleToLocationAsCost(loc) then return false end
	c:SetLocationAfterCost(loc)
	local res=c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(ARCHE_SCELUSPECTER) and Duel.IsExists(true,Card.IsCanBeEquippedWith,tp,0,LOCATION_MZONE,1,nil,c,e,tp,REASON_EFFECT)
	c:SetLocationAfterCost(0)
	return res
end
function s.ogcheck(n,g,eqg)
	return	function(og,e,tp,mg,c)
				if #og<n then return true end
				local eqg2=eqg:Clone()
				eqg2:Merge(og)
				return s.TryFindingNextValidEquipped(e,nil,n,g,eqg2,g:Clone(),eqg2:Clone())
			end
end
function s.tgcheck(n,eqg)
	return	function(g,e,tp,mg,c)
				if #g<n then return true end
				return s.TryFindingNextValidEquipped(e,nil,n,g,eqg,g:Clone(),eqg:Clone())
			end
end
function s.numcheck(i,tp,g,eqg,e,c)
	if not c:CheckRemoveOverlayCard(tp,i,REASON_COST) then return false end
	return s.TryFindingNextValidEquipped(e,c,i,g,eqg,g:Clone(),eqg:Clone())
end
function s.TryFindingNextValidEquipped(e,c,ft,g,eqg,gtocheck,eqgtocheck)
	for ec in aux.Next(eqg) do
		local res=s.CheckValidEquippedCombination(ec,e,c,ft,g,eqg,gtocheck,eqgtocheck)
		if res then
			return true
		end
	end
	return false
end
function s.CheckValidEquippedCombination(ec,e,c,ft,g,eqg,gtocheck,eqgtocheck)
	for tc in aux.Next(g) do
		local res=s.TryFindingValidEquipper(ec,tc,e,c,ft,g,eqg,gtocheck,eqgtocheck)
		if res then
			return true
		end
	end
	return false
end
function s.TryFindingValidEquipper(ec,tc,e,c,ft,g,eqg,gtocheck,eqgtocheck)
	if not tc:IsCanBeEquippedWith(ec,e,tp,REASON_EFFECT) then return false end
	ft=ft-1
	gtocheck:RemoveCard(tc)
	eqgtocheck:RemoveCard(ec)
	local res=ft==0 or s.TryFindingNextValidEquipped(e,c,ft,gtocheck,eqgtocheck,gtocheck,eqgtocheck)
	ft=ft+1
	gtocheck:AddCard(tc)
	eqgtocheck:AddCard(ec)
	return res
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqtofilter(chkc,e,tp) end
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local og=c:GetOverlayGroup()
	if chk==0 then
		if not (e:IsCostChecked() and ft>0) then return false end
		local ThereAreValidEquips=Duel.IsExists(true,s.eqtofilter,tp,0,LOCATION_MZONE,1,nil,e,tp)
		if ThereAreValidEquips then
			return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		else
			return og:IsExists(s.eqfilter_alt,1,nil,c,e,tp)
		end
	end
	local g=Duel.Group(Card.IsCanBeEquippedWith,tp,0,LOCATION_MZONE,nil,nil,e,tp,REASON_EFFECT):Filter(Card.IsCanBeEffectTarget,nil,e)
	local eqg0=Duel.Group(s.eqfilter_base,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
	local eqg1=eqg0:Clone()
	local eqg2=og:Filter(s.eqfilter_alt,nil,e,tp)
	eqg1:Merge(eqg2)
	local max=math.min(ft,c:GetOverlayCount())
	for i=max,1,-1 do
		if s.numcheck(i,tp,g,eqg1,e,c) then
			max=i
			break
		end
	end
	local n=Duel.AnnounceNumberMinMax(tp,1,max)
	if #eqg0>0 and s.numcheck(n,tp,g,eqg0,e,c) then
		c:RemoveOverlayCard(tp,n,n,REASON_COST)
	else
		local dg=aux.SelectUnselectGroup(eqg2,e,tp,n,n,s.ogcheck(n,g,eqg0),1,tp,HINTMSG_REMOVEXYZ)
		Duel.SendtoGrave(dg,REASON_COST)
		for tc in aux.Next(dg) do
			Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,REASON_COST,tp,0,0)
		end
		Duel.RaiseEvent(dg,EVENT_DETACH_MATERIAL,e,REASON_COST,tp,0,0)
	end
	local new_eqg=Duel.Group(s.eqfilter_base,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
	local tg=aux.SelectUnselectGroup(g,e,tp,n,n,s.tgcheck(n,new_eqg),1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_EQUIP)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<#g then return end
	local eqg=Duel.Group(aux.Necro(s.eqfilter_base),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
	local tg=g:Clone()
	while #tg>0 do
		local tc=tg:Select(tp,1,1,nil):GetFirst()
		Duel.HintSelection(Group.FromCards(tc))
		local ec=eqg:FilterSelect(tp,s.eqfilter_res,1,1,nil,tc,e,tp,#tg,tg,eqg,tg:Clone(),eqg:Clone()):GetFirst()
		if ec then
			Duel.EquipToOtherCardAndRegisterLimit(e,tp,ec,tc,true,true)
			tg:RemoveCard(tc)
			eqg:RemoveCard(ec)
		end
		Duel.EquipComplete()
	end
end