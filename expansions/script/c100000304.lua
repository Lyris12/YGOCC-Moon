--[[
Number C205: Dynastygian Dreadnought - "Punishment"
Numero C205: Corazzata Dinastigiana - "Punizione"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--4 Level 10 monsters
	aux.AddXyzProcedure(c,nil,12,5)
	--[[Must first be Special Summoned with a "Rank-Up-Magic" Spell targeting "Number 205: Dynastygian Dreadnought - "Judgement"".]]
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
	--[[If this card is Special Summoned, or if another "Dynastygian" monster(s) is Special Summoned to your field: You can choose 1 of your opponent's occupied Main Monster Zones
	or Spell & Trap Zones; banish the card in that zone, face-down, then if "Number 205: Dynastygian Dreadnought - "Judgement"" is attached to this card as material,
	banish all cards in the adjacent zones, face-down.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
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
	e2:SetCategory(CATEGORY_REMOVE)
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
	--[[At the start of the Standby Phase: You can detach as many materials from this card as possible (min. 4); all currently unoccupied Main Monster Zones
	and Spell & Trap Zones on the field cannot be used, then this card gains 500 ATK for each of those zones that cannot be used by this effect.
	These changes last until the end of the turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE_START|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetOperation(s.raise)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(s.zncon,s.zncost,s.zntg,s.znop)
	c:RegisterEffect(e4)
end
aux.xyz_number[id]=205

function s.rumlimit(mc,e,tp,c)
	return mc:IsCode(id-1)
end

--E0
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(ARCHE_RUM) and se:GetHandler():IsType(TYPE_SPELL)
		and se:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

--E1
function s.spcfilter(c,_,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsControler(tp)
end
function s.tgfilter(c,p,dzones)
	return c:GetSequence()<5 and c:IsAbleToRemove(p,POS_FACEDOWN,REASON_RULE) and (c:GetZone(p)<<16)&dzones==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tgfilter,tp,0,LOCATION_ONFIELD,nil,1-tp,Duel.GetDisabledZones(1-tp)<<16)
	if chk==0 then
		return Duel.IsPlayerCanRemove(1-tp) and #g>0
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
	Duel.SetCardOperationInfo(tc,CATEGORY_REMOVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=Duel.GetTargetParam()
	local loc=zone>>24~=0 and LOCATION_SZONE or LOCATION_MZONE
	local zoneCorrected=loc==LOCATION_MZONE and zone>>16 or zone>>24
	local g=Duel.GetCardsInZone(zoneCorrected,1-tp,loc)
	local tc=g:GetFirst()
	if tc and tc:IsAbleToRemove(1-tp,POS_FACEDOWN,REASON_RULE) and Duel.Remove(tc,POS_FACEDOWN,REASON_RULE,1-tp)>0 and c:IsRelateToChain() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,id-1) then
		local adg=Group.CreateGroup()
		
		local function optadd(location,sequence,player)
			local fc=Duel.GetFieldCard(1-tp,location,sequence)
			if fc then adg:AddCard(fc) end
		end
		
		local loc2=loc==LOCATION_MZONE and LOCATION_SZONE or LOCATION_MZONE
		local seq=math.log(zoneCorrected,2)
		if seq+1<=4 then optadd(loc,seq+1) end
		if seq-1>=0 then optadd(loc,seq-1) end
		optadd(loc2,seq)
		if loc==LOCATION_MZONE then
			if seq==1 then
				optadd(LOCATION_MZONE,5)
			elseif seq==3 then
				optadd(LOCATION_MZONE,6)
			end
		end
		adg=adg:Filter(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)
		if #adg>0 then
			Duel.BreakEffect()
			Duel.Remove(adg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

--E2
function s.raise(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
end

--E4
function s.zncon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:GetFirst()==e:GetHandler() and not Duel.CheckPhaseActivity()
end
function s.zncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:GetOverlayCount()
	for i=ct,1,-1 do
		if c:CheckRemoveOverlayCard(tp,i,REASON_COST) then
			c:RemoveOverlayCard(tp,i,i,REASON_COST)
			break
		end
	end
end
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones=0x1f|0x1f00|0x1f0000|0x1f000000
	local g=Duel.Group(Card.IsSequenceBelow,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,4)
	for tc in aux.Next(g) do
		local occupied=tc:GetZone(tp)
		if zones&occupied>0 then
			zones=zones&~occupied
		end
	end
	local dis1,dis2=Duel.GetDisabledZones()
	local dis=dis1|(dis2<<16)
	if chk==0 then return zones&~dis~=0 end
	local c=e:GetHandler()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,0)
end
function s.znop(e,tp,eg,ep,ev,re,r,p)
	local c=e:GetHandler()
	local zones=0x1f|0x1f00|0x1f0000|0x1f000000
	local g=Duel.Group(Card.IsSequenceBelow,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,4)
	for tc in aux.Next(g) do
		local occupied=tc:GetZone(tp)
		if zones&occupied>0 then
			zones=zones&~occupied
		end
	end
	local dis1,dis2=Duel.GetDisabledZones()
	local dis=dis1|(dis2<<16)
	local validZones=zones&~dis
	if validZones~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetValue(validZones)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.AdjustAll()
		local ndis1,ndis2=Duel.GetDisabledZones()
		local ndis=ndis1|(ndis2<<16)
		local affectedZones=ndis&~dis
		if affectedZones~=0 and c:IsRelateToChain() and c:IsFaceup() then
			local ct=0
			for _,j in ipairs({0,8,16,24}) do
				for k=0,4 do
					local z=1<<(k+j)
					if affectedZones&z~=0 then
						ct=ct+1
					end
				end
			end
			if ct>0 then
				Duel.BreakEffect()
				c:UpdateATK(ct*500,RESET_PHASE|PHASE_END)
			end
		end
	end
end