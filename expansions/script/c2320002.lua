--Galvanizer Strike
function c2320002.initial_effect(c)
	 --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,2320002+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetLabel(1)
	e1:SetTarget(c2320002.tg)
	e1:SetOperation(c2320002.op)
	c:RegisterEffect(e1)
--Draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2320002,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,2320002+EFFECT_COUNT_CODE_OATH)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetLabel(0)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c2320002.tg)
	e3:SetOperation(c2320002.op)
	c:RegisterEffect(e3)
end
function c2320002.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabel()+1
	if chk==0 then return Duel.IsPlayerCanDraw(tp,d) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(d)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
function c2320002.op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local g=Duel.GetDecktopGroup(p,d)
	Duel.Draw(p,d,REASON_EFFECT)
	local chk,rg=false,Group.CreateGroup()
	for tc in aux.Next(g) do
		Duel.ConfirmCards(1-p,tc)
		if not tc:IsSetCard(0x232) then
			rg=rg+tc
			chk=true
		end
	end
	if chk then
		Duel.BreakEffect()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		Duel.ShuffleHand(p)
	end
end
