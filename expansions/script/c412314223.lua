--created by Jake, coded by Lyris, art from Cardfight!! Vanguard's "Stealth Dragon, Voidgelga"
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x613),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.cost(e)
	e:SetLabel(9)
	return true
end
function s.cfilter(c,tp)
	return c:IsDiscardable() and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=9 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	local max=Duel.GetMatchingGroupCount(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if max>3 then max=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local ct=Duel.DiscardHand(tp,aux.OR(s.cfilter,aux.NOT(aux.FilterBoolFunction(Card.IsDiscardable))),1,max,REASON_COST+REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.get_zone(c,seq,ec)
	local zone,fl,l,r,fr,el,er,tp=0,0,1,3,4,5,6,ec:GetControler()
	if c:IsControler(1-tp) then fl,l,el,fr,r,er=fr,r,er,fl,l,el end
	if seq>0 and seq<=4 then
		if c:IsLinkMarker(LINK_MARKER_RIGHT) then zone=bit.replace(zone,0x1,seq+1) end
		if c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) then
			if seq==0 then zone=bit.replace(zone,0x1,el) end
			if seq==2 then zone=bit.replace(zone,0x1,er) end
		end
	end
	if seq<4 then
		if c:IsLinkMarker(LINK_MARKER_LEFT) then zone=bit.replace(zone,0x1,seq-1) end
		if c:IsLinkMarker(LINK_MARKER_TOP_LEFT) then
			if seq==2 then zone=bit.replace(zone,0x1,el) end
			if seq==4 then zone=bit.replace(zone,0x1,er) end
		end
	end
	if c:IsLinkMarker(LINK_MARKER_TOP) then
		if seq==1 then zone=bit.replace(zone,0x1,l) end
		if seq==3 then zone=bit.replace(zone,0x1,r) end
	end
	if seq==5 then
		if c:IsLinkMarker(LINK_MARKER_TOP) then zone=bit.replace(zone,0x1,r) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM) then zone=bit.replace(zone,0x1,l) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM_LEFT) then zone=bit.replace(zone,0x1,fl) end
		if c:IsLinkMarker(LINK_MARKER_TOP_LEFT) then zone=bit.replace(zone,0x1,fr) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM_RIGHT+LINK_MARKER_TOP_RIGHT) then zone=bit.replace(zone,0x1,2) end
	end
	if seq==6 then
		if c:IsLinkMarker(LINK_MARKER_TOP) then zone=bit.replace(zone,0x1,l) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM) then zone=bit.replace(zone,0x1,r) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM_RIGHT) then zone=bit.replace(zone,0x1,fr) end
		if c:IsLinkMarker(LINK_MARKER_TOP_RIGHT) then zone=bit.replace(zone,0x1,fl) end
		if c:IsLinkMarker(LINK_MARKER_BOTTOM_LEFT+LINK_MARKER_TOP_LEFT) then zone=bit.replace(zone,0x1,2) end
	end
	return zone
end
function s.filter(c,tp,e)
	local seq,ec=c:GetPreviousSequence(),e:GetHandler()
	local zone,cseq=ec:GetLinkedZone(),ec:GetSequence()
	if c:GetPreviousControler()~=tp then seq=seq+16 end
	local czone=s.get_zone(c,seq,ec)
	return ((c:GetLinkedGroup() and c:GetLinkedGroup():IsContains(ec)) or (ec:GetLinkedGroup() and ec:GetLinkedGroup():IsContains(c)))
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and (czone~=0 and bit.extract(czone,e:GetHandler():GetSequence())~=0 or bit.extract(zone,seq)~=0)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,e)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
