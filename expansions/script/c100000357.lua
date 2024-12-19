--[[
Vacuous Lord
Signore Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_VACUOUS_VASSAL,CARD_POWER_VACUUM_ZONE)
	--[[During the Main Phase (Quick Effect): You can banish 1 "Vacuous Vassal" from your field or GY; Special Summon this card from your hand, and if you do, negate the effects of 1 face-up card your
	opponent controls until the end of the 3rd turn after this effect resolves.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:HOPT()
	e1:SetFunctions(
		aux.MainPhaseCond(),
		aux.BanishCost(s.cfilter,LOCATION_ONFIELD|LOCATION_GRAVE,0,1),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If you control "Power Vacuum Zone": You can banish 1 card your opponent controls, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1),
		nil,
		xgl.SendtoTarget(LOCATION_REMOVED,nil,aux.TRUE,0,LOCATION_ONFIELD,1,1,nil,POS_FACEDOWN),
		xgl.SendtoOperation(LOCATION_REMOVED,nil,aux.TRUE,0,LOCATION_ONFIELD,1,1,nil,POS_FACEDOWN)
	)
	c:RegisterEffect(e2)
	--[[While there is a face-up "Power Vacuum Zone" in your Field Zone, negate the effects of all monsters your opponent controls during the Battle Phase only.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(aux.AND(aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_FZONE,0,1),aux.BattlePhaseCond()))
	e3:SetTarget(s.disable)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_VACUOUS_VASSAL) and Duel.GetMZoneCount(tp,c)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and #g>0
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_DISABLE,false,tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e)
		if Duel.Highlight(g) then
			local e1,e2,e3,res=Duel.Negate(g:GetFirst(),e,{RESET_PHASE|PHASE_END,3})
			local effs={e1,e2,e3}
			if res==nil then
				res=e3
				table.remove(effs,#effs)
			end
			if res then
				aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,3,nil,nil,table.unpack(effs))
			end
		end
	end
end

--E3
function s.disable(e,c)
	return c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT
end