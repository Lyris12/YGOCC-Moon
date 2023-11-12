--The Horror That Time Laments
--L'Orrore che il Tempo Lamenta
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,10,s.TLcon,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND))
	c:EnableReviveLimit()
	--[[ If this card is Time Leap Summoned: You can reveal 1 Drive Monster from your Deck; add it to your hand, then reveal it,
	and if you do, if there are any Engaged Drive Monsters, reduce their Energy by the Energy of that revealed monster, otherwise Engage that revealed monster.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetCustomCategory(CATEGORY_UPDATE_ENERGY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.TimeleapSummonedCond,aux.DummyCost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[When a Drive Effect is activated (Quick Effect): You can banish 1 other card on the field, face-down (until the end of the next turn),
	also the zone that card was in cannot be used while it remains banished.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
	--[[Each time a Drive Monster(s) is Special Summoned, or the Energy of a Drive Monster(s) becomes 0, this card and all Drive Monsters you currently control immediately gain 700 ATK/350 DEF.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon1)
	e3:SetOperation(s.atkop1)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetCode(EVENT_ENERGY_CHANGE)
	c:RegisterEffect(e3x)
	--sp_summon effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_ENERGY_CHANGE)
	c:RegisterEffect(e4x)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon2)
	e5:SetOperation(s.atkop2)
	c:RegisterEffect(e5)
end
function s.TLcon(e,c,tp)
	local en=Duel.GetEngagedCard(tp)
	return en and en:IsMonster(TYPE_DRIVE) and en:IsEnergyAbove(21)
end

--E1
function s.filter(c,e,tp,ct)
	return c:IsMonster(TYPE_DRIVE) and c:IsAbleToHand() and (ct>0 or c:IsCanEngage(tp,false,e))
end
function s.enfilter(c,e,tp,ct)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanUpdateEnergy(ct,tp,REASON_EFFECT,e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetEngagedCards():FilterCount(Card.IsMonster,nil,TYPE_DRIVE)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ct)
	end
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ct)
	if #g<=0 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.SetTargetCard(g)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	local ng=Duel.GetEngagedCards():Filter(Card.IsMonster,nil,TYPE_DRIVE)
	if #ng>0 then
		Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,ng,#ng,INFOFLAG_DECREASE,g:GetFirst():GetEnergy())
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SearchAndCheck(tc,tp,nil,true) then
		local ct=tc:GetEnergy()
		local g=Duel.GetEngagedCards():Filter(Card.IsMonster,nil,TYPE_DRIVE)
		if #g>0 then
			local tg=g:Filter(s.enfilter,nil,e,tp,ct)
			for en in aux.Next(tg) do
				en:UpdateEnergy(-ct,tp,REASON_EFFECT,true,e:GetHandler(),e,nil,true)
			end
			Duel.UpdateEnergyComplete()
		else
			if tc:IsCanEngage(tp,false,e) then
				tc:Engage(e,tp)
			end
		end
	end
end

--E2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if te:IsDriveEffect() then
			return true
		end
	end
	return false
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp,POS_FACEDOWN)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThis(c),tp,POS_FACEDOWN)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.HintSelection(g)
		if Duel.BanishUntil(tc,e,tp,POS_FACEDOWN,PHASE_END,id,2,false,c,REASON_EFFECT,false,false,nil,nil,id+100)>0 and tc:IsBanished(POS_FACEDOWN) then
			if not tc:IsPreviousLocation(LOCATION_FZONE) then
				tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,0,1)
				local zone=tc:GetPreviousZone(tp)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE_FIELD)
				e1:SetLabel(zone)
				e1:SetLabelObject(tc)
				e1:SetCondition(s.discon)
				e1:SetOperation(s.disop)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.discon(e)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffect(id+100) then
		e:Reset()
		return false
	end
	return true
end
function s.disop(e,tp)
	return e:GetLabel()
end

--E3+
function s.cfilter(c,enchk,ev)
	if not enchk and not c:IsFaceup() then return false end
	return c:IsMonster(TYPE_DRIVE) and (not enchk or ((c:GetEnergy()==0 or c:HasFlagEffect(FLAG_ZERO_ENERGY))
		and (ev~=0 or (c:HasFlagEffect(FLAG_ENERGY_CHANGE) and aux.FixNegativeLabel(c:GetFlagEffectLabel(FLAG_ENERGY_CHANGE))~=0))))
end
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	local enchk=true
	if e:GetCode()==EVENT_SPSUMMON_SUCCESS then
		enchk=false
	end
	return eg:IsExists(s.cfilter,1,nil,enchk,ev) 
		and (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsMonster,TYPE_DRIVE),tp,LOCATION_MZONE,0,nil)
	g:AddCard(c)
	for tc in aux.Next(g) do
		tc:UpdateATKDEF(700,350,true,{c,true})
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local enchk=true
	if e:GetCode()==EVENT_SPSUMMON_SUCCESS then
		enchk=false
	end
	return eg:IsExists(s.cfilter,1,nil,enchk,ev) 
		and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+200,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+200)>0
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffect(id+200)
	if ct<=0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.ResetFlagEffect(tp,id+200)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsMonster,TYPE_DRIVE),tp,LOCATION_MZONE,0,nil)
	g:AddCard(c)
	for tc in aux.Next(g) do
		for i=1,ct do
			tc:UpdateATKDEF(700,350,true,{c,true})
		end
	end
end