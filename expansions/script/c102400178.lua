--created & coded by Lyris, art by CoolCatFlora of DeviantArt
--ニュートリックス・アイスィー
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,3,99,cid.lcheck)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.discon)
	e2:SetOperation(cid.disop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.lcheck(g)
	return g:GetClassCount(Card.GetLinkAttribute)==1 and g:GetClassCount(Card.GetLinkRace)==1 and g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER)
	return re:IsActiveType(TYPE_LINK) and p~=tp and Duel.IsExistingMatchingCard(function(tc,lpt) return tc:GetLinkMarker()&lpt>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLinkMarker())
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function cid.lfilter(c,tp)
	return Duel.IsExistingMatchingCard(function(tc,lpt) return tc:GetLinkMarker()&lpt>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLinkMarker())
end
function cid.filter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cid.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>-1
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local lpt,nlpt=tc:GetLinkMarker(),0
	local j=0
	for i=0,8 do
		j=0x1<<i&lpt
		if j>0 and cid.link_table[op][j] then
			nlpt=nlpt|j
		end
	end
	if nlpt==lpt then return end
	Duel.BreakEffect()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e1:SetValue(nlpt)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
cid.link_table={
	[LINK_MARKER_BOTTOM_LEFT]=LINK_MARKER_TOP_LEFT,
	[LINK_MARKER_BOTTOM]=LINK_MARKER_TOP,
	[LINK_MARKER_BOTTOM_RIGHT]=LINK_MARKER_TOP_RIGHT,
	[LINK_MARKER_TOP_LEFT]=LINK_MARKER_BOTTOM_LEFT,
	[LINK_MARKER_TOP]=LINK_MARKER_BOTTOM,
	[LINK_MARKER_TOP_RIGHT]=LINK_MARKER_BOTTOM_RIGHT,
}
