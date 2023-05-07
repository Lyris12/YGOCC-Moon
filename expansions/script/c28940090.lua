--Monkastery Arte - Skysplit
local ref,id=GetID()
Duel.LoadScript("Monkastery.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Optional Cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(ref.costtg)
	e2:SetCost(ref.costchk)
	e2:SetOperation(ref.costop)
	c:RegisterEffect(e2)
end

--Activate
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetParam(1000)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,Monkastery.Code+0x1000) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function ref.actop(e,tp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Recover(p,val,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,Monkastery.Code+0x1000) and Duel.IsPlayerCanDraw(p,1) then
		Duel.BreakEffect()
		Duel.Draw(p,1,REASON_EFFECT)
	end
end

--Optional Cost
function ref.costtg(e,te,tp)
	e:SetLabelObject(te)
	return te:GetHandler():IsSetCard(Monkastery.Code)
end
function ref.costchk(e,te_or_c,tp)
	return true
end
function ref.costop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	if c:IsAbleToRemoveAsCost() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and Duel.Remove(c,POS_FACEUP,REASON_COST)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(ref.chop)
		e1:SetLabelObject(e:GetLabelObject())
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function ref.chop(e,tp,eg,ep,ev,re,r,rp)
	if re==e:GetLabelObject() then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.SetChainLimit(ref.chainlm)
	end
end
function ref.chainlm(e,rp,tp)
	return tp==rp
end
