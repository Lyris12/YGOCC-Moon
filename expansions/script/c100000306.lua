--[[
Number iC212: Dynastygian Fortress - "Star Eater"
Numero iC212: Fortezza Dinastigiana - "Divoratore di Stelle"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3+ Level 11 Machine monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),11,3,nil,nil,99)
	--[[Must first be Special Summoned with a "Rank-Up-Magic" Spell targeting "Number i212: Dynastygian Fortress - World Eater".]]
	if not s.rum_limit then
		s.rum_limit=aux.CreateRUMLimitFunction(s.rumlimit)
	end
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--[[This card is unaffected by other cards and effects while it has material.]]
	c:Unaffected(UNAFFECTED_OTHER,s.imcon)
	--[[If this card is Xyz Summoned: Return as many cards your opponent controls to the hand as possible, also, if the zones those returned cards were in are now unoccupied,
	they cannot be used until the end of the 3rd turn after this effect resolves, also you cannot conduct your Battle Phase until the end of the 3rd turn after this effect resolves.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
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
	--[[During the Main Phase, while this card has "Number i212: Dynastygian Fortress - "World Eater" as material (Quick Effect): You can detach 1 material from this card, choose either you or your
	opponent, then send 1 "Dynastgian" Normal Trap from your hand or Deck to the GY that meets its activation requirements; this effect becomes that Trap's effect when that card is activated by the
	chosen player.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetRelevantTimings()
	e3:SetFunctions(s.applycon,aux.DummyCost,s.applytg,s.applyop)
	c:RegisterEffect(e3)
end
aux.xyz_number[id]=212

function s.rumlimit(mc,e,tp,c)
	return mc:IsCode(id-1)
end

function s.imcon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
--E0
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(ARCHE_RUM) and se:GetHandler():IsType(TYPE_SPELL)
		and se:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local g=Duel.Group(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,1-tp,LOCATION_ONFIELD)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg
	local g=Duel.Group(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		sg=Duel.GetGroupOperatedByThisEffect(e):Filter(aux.NOT(Card.IsOnField),nil)
	end
	local pyroClockEffects={}
	if sg and #sg>0 then
		local zones=0
		for tc in aux.Next(sg) do
			if tc:IsPreviousLocation(LOCATION_MZONE) or tc:GetPreviousSequence()<5 then
				local zone=tc:GetPreviousZone(tp)
				zones=zones|zone
			end
		end
		local freezones=zones&~(Duel.GetDisabledZones(1-tp)<<16)
		local exczones=0
		local fg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE|LOCATION_SZONE)
		for tc in aux.Next(fg) do
			local zone=tc:GetZone(1-tp)<<16
			exczones=exczones|zone
		end
		freezones=freezones&~exczones
		if freezones~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetValue(freezones)
			e1:SetReset(RESET_PHASE|PHASE_END,3)
			Duel.RegisterEffect(e1,tp)
			table.insert(pyroClockEffects,e1)
		end
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE|PHASE_END,3)
	Duel.RegisterEffect(e2,tp)
	table.insert(pyroClockEffects,e2)
	aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,3,nil,nil,table.unpack(pyroClockEffects))
end

--E2
function s.applycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,id-1)
end
function s.filter(c)
	if not (c:IsNormalTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsAbleToGraveAsCost()) then return false end
	local check=false
	for p=0,1 do
		Duel.RegisterFlagEffect(0,id,0,0,0,p)
		if c:CheckActivateEffect(false,true,true)~=nil then
			check=true
			break
		end
		Duel.ResetFlagEffect(0,id)
	end
	return check
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil)
	end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
	local players,params={},{}
	for p=tp,1-tp,1-2*tp do
		Duel.RegisterFlagEffect(0,id,0,0,0,p)
		local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
		Duel.ResetFlagEffect(0,id)
		if te then
			params[p]={te,ceg,cep,cev,cre,cr,crp}
			table.insert(players,p)
		end
	end
	local p
	if #players>1 then
		local opt=Duel.SelectOption(tp,STRING_SELF,STRING_OPPO)
		p=opt==0 and tp or 1-tp
	else
		p=players[1]
	end
	e:SetLabel(p)
	Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,0,p)
	local te,ceg,cep,cev,cre,cr,crp=table.unpack(params[p])
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.ResetFlagEffect(0,id)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,0,e:GetLabel())
		op(e,tp,eg,ep,ev,re,r,rp)
		Duel.ResetFlagEffect(0,id)
	end
end