--Ennigmatic Clairvoyance
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.sctg)
	e1:SetOperation(cid.scop)
	c:RegisterEffect(e1)
end
--filters
function cid.filter(c,rg)
	if not c:IsFaceup() or not c:IsType(TYPE_XYZ) or not c:IsSetCard(0x2ead) or c:GetRank()<=0 then return false end
	local result=false
	if rg:IsContains(c) then
		rg:RemoveCard(c)
		result=rg:IsExists(cid.levelchk,1,nil,c:GetRank(),nil)
		rg:AddCard(c)
	else
		result=rg:IsExists(cid.levelchk,1,nil,c:GetRank(),nil)
	end
	return result
end
function cid.levelchk(c,rk,g)
	return c:GetLevel()<=rk and (not g or not g:IsContains(c))
end
function cid.scfilter(c)
	return c:IsSetCard(0x1ead) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end 
--Activate
function cid.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local rg=Duel.GetMatchingGroup(cid.scfilter,tp,LOCATION_DECK,0,nil)
		return #rg>0 and Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil,rg)
	end
	local rg=Duel.GetMatchingGroup(cid.scfilter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil,rg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,rg,1,0,0)
end
function cid.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local rg=Duel.GetMatchingGroup(cid.scfilter,tp,LOCATION_DECK,0,nil)
	if #rg<=0 then return end
	local maxct,ct=tc:GetRank(),0
	local g=Group.CreateGroup()
	g:KeepAlive()
	local ok=true
	while ok do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local rm=rg:FilterSelect(tp,cid.levelchk,1,1,nil,tc:GetRank(),g)
		ct=ct+rm:GetFirst():GetLevel()
		g:AddCard(rm:GetFirst())
		if ct<maxct and rg:IsExists(cid.levelchk,1,nil,maxct-ct,g) then
			ok=Duel.SelectYesNo(tp,aux.Stringid(id,1))
		else
			ok=false
		end
	end
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local x=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
		if #x>0 then
			Duel.ConfirmCards(1-tp,x)
			Duel.Overlay(tc,x)
		end
	end
end