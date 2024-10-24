--Path of the Lotus Blade - Discovery
--Commissioned by: Leon Duvall
--Scripted by: Remnance & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--excavate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.thcon)
	e2:SetTarget(cid.thtg)
	e2:SetOperation(cid.thop)
	c:RegisterEffect(e2)
end
--filters
function cid.thfilter(c)
	return c:IsSetCard(0x3ff) and c:IsAbleToHand()
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ff)
end
--Activate
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.PlayerHasFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY) or (Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.GetDecktopGroup(tp,3):FilterCount(Card.IsAbleToHand,nil)>0)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and (Duel.PlayerHasFlagEffect(tp,CARD_LOTUS_BLADE_MIMICRY) or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.ConfirmDecktop(tp,3)
		local g=Duel.GetDecktopGroup(tp,3)
		if g:GetCount()>0 and g:IsExists(cid.thfilter,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp,cid.thfilter,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
		end
		Duel.ShuffleDeck(tp)
	end
end
--excavate
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ex=Duel.GetDecktopGroup(tp,5)
	Duel.ConfirmCards(tp,ex)
	local t={}
	for i=0,#ex do table.insert(t,i) end
	local j=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.SortDecktop(tp,tp,5)
	for k=1,j do Duel.MoveSequence(Duel.GetDecktopGroup(tp,1):GetFirst(),1) end
	Duel.BreakEffect()
	Duel.ConfirmCards(tp,Duel.GetDecktopGroup(tp,5-j))
end
