--[[
Lich-Lord's Burial Grounds
Terreni di Sepoltura del Signore-Lich
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Lich-Lord's Burial Grounds".
	c:SetUniqueOnField(1,0,id)
	c:Activation()
	--While you have "Lich-Lord's Phylactery" in your GY, all "Lich-Lord" monsters you control gain 100 ATK/DEF for each Zombie monster on the field and in the GYs.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(aux.PhylacteryCondition)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_LICH_LORD))
	e2:SetValue(s.statval)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	--Once per turn, if you control no monsters: You can Special Summon 1 "Lich-Lord" monster from your hand or GY, and if you do, negate its effects on the field until your next Main Phase.
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e3)
	--[[If this card and "Lich-Lord's Phylactery" are in your GY, except the turn this card was sent there: You can banish this card and up to 5 Zombie monsters from your GY;
	destroy all monsters you control (if any), then Special Summon "Lich-Lord" monsters from your hand, Deck, or GY, up to the number of Zombie monsters banished to activate this effect.
	Their effects are negated, also their original Levels become 7.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:HOPT()
	e4:SetFunctions(s.spcon,aux.DummyCost,s.sptg,s.spop)
	c:RegisterEffect(e4)
end

--E2
function s.statfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_ZOMBIE)
end
function s.statval(e,c)
	return Duel.GetMatchingGroupCount(s.statfilter,0,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil)*100
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local turnct,ph=-1,0
		if Duel.IsMainPhase(tp) then
			turnct,ph=Duel.GetTurnCount(),Duel.GetCurrentPhase()
		end
		Duel.Negate(tc,e,0,false,false,TYPE_MONSTER,s.resetcon(tp,turnct,ph))
	end
end
function s.resetcon(tp,turnct,ph)
	return	function(e)
				if Duel.IsMainPhase(tp) and (turnct==-1 or Duel.GetTurnCount()~=turnct or (ph~=0 and Duel.GetCurrentPhase()~=ph)) then
					e:Reset()
					return false
				end
				return true
			end
end

--E4
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.PhylacteryCheck(tp) and aux.exccon(e,tp,eg,ep,ev,re,r,rp)
end
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
function s.rescon(dg)
	return	function(g,e,tp)
				local res=Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,g,e,tp)
				return (Duel.GetMZoneCount(tp,g)>0 or Duel.GetMZoneCount(tp,dg)>0) and res, not res
			end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.cfilter,tp,LOCATION_GRAVE,0,c)
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if chk==0 then
		return e:IsCostChecked() and c:IsAbleToRemoveAsCost() and aux.SelectUnselectGroup(g,e,tp,1,5,s.rescon(dg),0)
	end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,5,s.rescon(dg),1,tp,HINTMSG_REMOVE)
	if #rg>0 then
		rg:AddCard(c)
		local ct=Duel.Remove(rg,POS_FACEUP,REASON_COST)
		if Duel.GetOperatedGroup():IsContains(c) then
			ct=ct-1
		end
		Duel.SetTargetParam(ct)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local check,breakchk=true,false
	if #dg>0 then
		check=Duel.Destroy(dg,REASON_EFFECT)>0
		breakchk=true
	end
	if check then
		local ct=Duel.GetTargetParam()
		if not ct then return end
		local ft=Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or math.min(ct,Duel.GetMZoneCount(tp))
		if ft<=0 then return end
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,ft,nil,e,tp)
		if #g>0 then
			if breakchk then
				Duel.BreakEffect()
			end
			local c=e:GetHandler()
			local eid=e:GetFieldID()
			for tc in aux.Next(g) do
				if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e1,true)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e2,true)
					local temp=tc:GetOriginalLevel()
					if temp~=7 then
						tc:SetCardData(CARDDATA_LEVEL,7)
						tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_TOFIELD,0,1,eid)
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
						e3:SetCode(EVENT_ADJUST)
						e3:SetLabel(eid)
						e3:SetLabelObject(tc)
						e3:SetOperation(s.resetlv(temp))
						Duel.RegisterEffect(e3,tp)
					end
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.resetlv(temp)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local eid=e:GetLabel()
				local tc=e:GetLabelObject()
				if not tc or not tc:HasFlagEffectLabel(id,eid) then
					tc:SetCardData(CARDDATA_LEVEL,temp)
					e:Reset()
				end
			end
end