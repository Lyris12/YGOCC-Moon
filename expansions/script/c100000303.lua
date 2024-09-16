--[[
Number 205: Dynastygian Dreadnought - "Judgement"
Numero 205: Corazzata Dinastigiana - "Giudizio"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--4 Level 10 monsters
	aux.AddXyzProcedure(c,nil,10,4)
	--Must first be Xyz Summoned
	c:MustFirstBeSummoned(SUMMON_TYPE_XYZ)
	--[[If this card is Xyz Summoned, or if another Machine Xyz Monster(s) is Special Summoned to your field: You can choose 1 of your opponent's occupied Main Monster Zones
	or Spell & Trap Zones; your opponent must send the card in that Zone to the GY. Cards sent to the GY this way cannot activate their effects during that same turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE)
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
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e2:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.spcfilter),
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e2)
	--[[During your Main Phase: You can detach 1 or 2 materials from this card; apply 1 of the following effects, depending on the number of materials you detached.
	● 1: Inflict damage to your opponent equal to the highest original ATK or DEF (whichever is higher) among face-up monsters on the field (your choice, if tied).
	● 2: The ATK/DEF of all face-up monsters your opponent currently controls becomes halved, then this card gains ATK/DEF equal to that total lost ATK/DEF (max. 4000).
	These changes last until the end of the turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		aux.DummyCost,
		s.applytg,
		s.applyop
	)
	c:RegisterEffect(e3)
end
aux.xyz_number[id]=205

--E1
function s.spcfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and c:IsControler(tp)
end
function s.tgfilter(c,p,dzones)
	return c:GetSequence()<5 and Duel.IsPlayerCanSendtoGrave(p,c) and (c:GetZone(p)<<16)&dzones==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tgfilter,tp,0,LOCATION_ONFIELD,nil,1-tp,Duel.GetDisabledZones(1-tp)<<16)
	if chk==0 then
		return #g>0
	end
	local exczones=0
	for tc in aux.Next(g) do
		local zone=tc:GetZone(1-tp)<<16
		exczones=exczones|zone
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local zone=Duel.SelectField(tp,1,0,LOCATION_MZONE|LOCATION_SZONE,(~exczones)|(0x60<<16))
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.SetTargetParam(zone)
	local loc=zone>>24~=0 and LOCATION_SZONE or LOCATION_MZONE
	local g=loc==LOCATION_MZONE and Duel.GetCardsInZone(zone>>16,1-tp,loc) or Duel.GetCardsInZone(zone>>24,1-tp,loc)
	local tc=g:GetFirst()
	Duel.SetCardOperationInfo(tc,CATEGORY_TOGRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=Duel.GetTargetParam()
	local loc=zone>>24~=0 and LOCATION_SZONE or LOCATION_MZONE
	local g=loc==LOCATION_MZONE and Duel.GetCardsInZone(zone>>16,1-tp,loc) or Duel.GetCardsInZone(zone>>24,1-tp,loc)
	local tc=g:GetFirst()
	if tc and Duel.IsPlayerCanSendtoGrave(1-tp,tc) and Duel.SendtoGrave(tc,REASON_RULE,1-tp)>0 and tc:IsLocation(LOCATION_GRAVE) and aux.BecauseOfThisRule(e)(tc) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_TRIGGER)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--E2
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local _,val=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetMaxBaseStat)
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST) and val>0
	local b2=c:CheckRemoveOverlayCard(tp,2,REASON_COST) and #g>0
	if chk==0 then
		return e:IsCostChecked() and (b1 or b2)
	end
	local min=b1 and 1 or 2
	local max=b2 and 2 or min
	local ct=c:RemoveOverlayCard(tp,min,max,REASON_COST)
	Duel.SetTargetParam(ct)
	if ct==1 then
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(1-tp)
		_,val=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetMaxBaseStat)
		aux.DamageInfo(1-tp,val)
	elseif ct==2 then
		e:SetCategory(CATEGORIES_ATKDEF)
		e:SetProperty(0)
		local tatk,tdef=0,0
		for tc in aux.Next(g) do
			local atk,def=math.floor(tc:GetAttack()/2 + 0.5),math.floor(tc:GetDefense()/2 + 0.5)
			if tatk<4000 then
				tatk=math.min(tatk+atk,4000)
			end
			if tdef<4000 then
				tdef=math.min(tdef+def,4000)
			end
		end
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,0,0,0,OPINFO_FLAG_HALVE)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,tatk)
		Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,c,1,0,0,tdef)
	end
end
function s.applyop(e,tp,eg,ep,ev,re,r,p)
	local ct=Duel.GetTargetParam()
	if ct==1 then
		local _,val=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetMaxBaseStat)
		if val>0 then
			Duel.Damage(Duel.GetTargetPlayer(),val,REASON_EFFECT)
		end
	elseif ct==2 then
		local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		local c=e:GetHandler()
		local tatk,tdef=0,0
		local rc={c,true}
		for tc in aux.Next(g) do
			local e1,_,_,diff1=tc:HalveATK(RESET_PHASE|PHASE_END,rc)
			local e2,_,_,diff2=tc:HalveDEF(RESET_PHASE|PHASE_END,rc)
			if tatk<4000 and not tc:IsImmuneToEffect(e1) and diff1<0 then
				tatk=math.min(tatk-diff1,4000)
			end
			if tdef<4000 and not tc:IsImmuneToEffect(e2) and diff2<0 then
				tdef=math.min(tdef-diff2,4000)
			end
		end
		if c:IsRelateToChain() and c:IsFaceup() then
			Duel.BreakEffect()
			if tatk>0 then c:UpdateATK(tatk,RESET_PHASE|PHASE_END,rc) end
			if tdef>0 then c:UpdateDEF(tdef,RESET_PHASE|PHASE_END,rc) end
		end
	end
end