--Evolute Withdraw
function c16001001.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	 e1:SetCountLimit(1,16001001)
	e1:SetCost(c16001001.drcost)
	e1:SetTarget(c16001001.drtg)
	e1:SetOperation(c16001001.drop)
	c:RegisterEffect(e1)
end

function c16001001.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveEC(tp,1,0,5,REASON_COST) and Duel.CheckReleaseGroup(tp,Card.IsReleasable,1,nil,nil) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsReleasable,1,1,nil,nil)
	Duel.RemoveEC(tp,1,0,5,REASON_COST)
	Duel.Release(g,REASON_COST)
end
function c16001001.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c16001001.drop(e,tp,eg,ep,ev,re,r,rp,chk)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end