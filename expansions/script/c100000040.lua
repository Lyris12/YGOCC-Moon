--Hurlement du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Destroy 1 Pendulum Monster Card you control and 1 card your opponent controls, and if you do, if destroyed a Ritual Monster(s), send 1 card they control to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c)
	return c:GetOriginalType()&(TYPE_MONSTER|TYPE_PENDULUM)==TYPE_MONSTER|TYPE_PENDULUM 
end
function s.chkfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousTypeOnField(TYPE_RITUAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.Group(s.filter1,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.Group(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then
		return #g1>0 and #g2>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1:Merge(g2),2,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Group(s.filter1,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.Group(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if #g1>0 and #g2>0 then
		local sg1=Duel.Select(HINTMSG_DESTROY,false,tp,s.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #sg1>0 then
			local sg2=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,sg1)
			sg1:Merge(sg2)
			Duel.HintSelection(sg1)
			if Duel.Destroy(sg1,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsExists(s.chkfilter,1,nil) then
				local sg3=Duel.Select(HINTMSG_TOGRAVE,false,tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
				if #sg3>0 then
					Duel.HintSelection(sg3)
					Duel.SendtoGrave(sg3,REASON_EFFECT)
				end
			end
		end
	end		
end