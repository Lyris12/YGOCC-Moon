--created & coded by Lyris, art by wawa3761 of DeviantArt
--ニュートリックス・ギャブリー
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,2,cid.lcheck)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(cid.lfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.lcheck(g)
	return g:GetClassCount(Card.GetLinkAttribute)==1 and g:GetClassCount(Card.GetLinkRace)==1 and g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
function cid.lfilter(c,tp)
	return Duel.IsExistingMatchingCard(function(tc,lpt) return tc:GetLinkMarker()&lpt>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLinkMarker())
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,0,REASON_COST)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0xd10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and cid.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 or not tc:IsType(TYPE_LINK) then return end
	local op=Duel.AnnounceNumber(tp,1,1,2,3)
	local lpt,nlpt=tc:GetLinkMarker(),0
	local j=0
	for i=0,8 do
		j=0x1<<i&lpt
		if j>0 and cid.link_table[op][j] then
			nlpt=nlpt|cid.link_table[op][j]
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
	[1]={
		[LINK_MARKER_BOTTOM_LEFT]=LINK_MARKER_BOTTOM,
		[LINK_MARKER_BOTTOM]=LINK_MARKER_BOTTOM_RIGHT,
		[LINK_MARKER_BOTTOM_RIGHT]=LINK_MARKER_RIGHT,
		[LINK_MARKER_LEFT]=LINK_MARKER_BOTTOM_LEFT,
		[LINK_MARKER_RIGHT]=LINK_MARKER_TOP_RIGHT,
		[LINK_MARKER_TOP_LEFT]=LINK_MARKER_LEFT,
		[LINK_MARKER_TOP]=LINK_MARKER_TOP_LEFT,
		[LINK_MARKER_TOP_RIGHT]=LINK_MARKER_TOP,
	},
	[2]={
		[LINK_MARKER_BOTTOM_LEFT]=LINK_MARKER_BOTTOM_RIGHT,
		[LINK_MARKER_BOTTOM]=LINK_MARKER_RIGHT,
		[LINK_MARKER_BOTTOM_RIGHT]=LINK_MARKER_TOP_RIGHT,
		[LINK_MARKER_LEFT]=LINK_MARKER_BOTTOM,
		[LINK_MARKER_RIGHT]=LINK_MARKER_TOP,
		[LINK_MARKER_TOP_LEFT]=LINK_MARKER_BOTTOM_LEFT,
		[LINK_MARKER_TOP]=LINK_MARKER_LEFT,
		[LINK_MARKER_TOP_RIGHT]=LINK_MARKER_TOP_LEFT,
	},
	[3]={
		[LINK_MARKER_BOTTOM_LEFT]=LINK_MARKER_BOTTOM,
		[LINK_MARKER_BOTTOM]=LINK_MARKER_TOP_RIGHT,
		[LINK_MARKER_BOTTOM_RIGHT]=LINK_MARKER_RIGHT,
		[LINK_MARKER_LEFT]=LINK_MARKER_BOTTOM_RIGHT,
		[LINK_MARKER_RIGHT]=LINK_MARKER_TOP_LEFT,
		[LINK_MARKER_TOP_LEFT]=LINK_MARKER_TOP,
		[LINK_MARKER_TOP]=LINK_MARKER_BOTTOM_LEFT,
		[LINK_MARKER_TOP_RIGHT]=LINK_MARKER_LEFT,
	},
}
