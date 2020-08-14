--coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsSetCard,0x617),2,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetCondition(cid.tgcon)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.tgtg)
	e1:SetOperation(cid.tgop)
	c:RegisterEffect(e1)
end
function cid.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function cid.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x617) and c:IsAbleToRemoveAsCost()
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA),3),nil)
	e:SetLabel(#g)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local tg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,tg)
	if tg:GetClassCount(Card.GetCode)>=ct then
		local rg=Group.CreateGroup()
		for i=1,ct do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tc=tg:Select(tp,1,1,nil):GetFirst()
			if tc then
				rg:AddCard(tc)
				tg:Remove(Card.IsCode,nil,tc:GetCode())
			end
		end
		Duel.SendtoGrave(rg,REASON_EFFECT)
		local dg=Duel.GetOperatedGroup()
		if dg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==ct then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
