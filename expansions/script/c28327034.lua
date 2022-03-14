--灯火之温泉
local m=28327034
local cm=_G["c"..m]
Duel.LoadScript("c28327000.lua")
function cm.initial_effect(c)
	aux.AddCodeList(c,28327000)
	--
	local e1=aux.AddRitualProcGreater2(c,cm.filter,LOCATION_REMOVED+LOCATION_GRAVE)   
	e1:SetCountLimit(1,m)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,m+900)
	e2:SetCondition(aux.exccon)
	e2:SetCost(cm.setcost)
	e2:SetTarget(cm.settg)
	e2:SetOperation(cm.setop)
	c:RegisterEffect(e2)
end
function cm.filter(c)
	return aux.IsCodeListed(c,28327000) and c:IsType(TYPE_RITUAL) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function cm.costfilter(c)
	return c:IsCode(28327000) and c:IsDiscardable()
end
function cm.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,cm.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
function cm.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function cm.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end
