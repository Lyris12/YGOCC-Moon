--Zero HERO Magma Man
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2)
	--Register ATK boost depending on other cards' ATKs
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(CARD_ZERO_HERO_MAGMA_MAN)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(scard.atkval)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:SetCountLimit(1)
	e2:SetCondition(scard.condition)
	e2:SetTarget(scard.sptg)
	e2:SetOperation(scard.spop)
	c:RegisterEffect(e2)
end
function scard.nfilter(c)
	return c:IsFaceup() and not c:IsCode(s_id) and not c:IsHasEffect(CARD_ZERO_HERO_MAGMA_MAN) and (not c:IsHasEffect(CARD_WICKED_AVATAR) or c:IsDisabled())
end
function scard.atkval(e,c)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if not lg then return 0 end
	return lg:Filter(scard.nfilter,c):GetSum(Card.GetAttack)
end

function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function scard.spfilter(c,e,tp,zones)
	if not c:IsSetCard(0x8) then return false end
	for p=tp,1-tp,1-2*tp do
		local zone=zones[p+1]&0xff
		if Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,p,zone) then
			return true
		end
	end
	return false
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zones={}
	for p=tp,1-tp,1-2*tp do
		table.insert(zones,c:GetLinkedZone(p))
	end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and scard.spfilter(chkc,e,tp,zones) end
	if chk==0 then return Duel.IsExistingTarget(scard.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zones) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,scard.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zones)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToChain() or c:IsFacedown() or not c:IsType(TYPE_LINK) or not tc or not tc:IsRelateToChain() then return end
	local check=false
	local bs={}
	local zones={}
	for p=tp,1-tp,1-2*tp do
		table.insert(zones,c:GetLinkedZone(p))
	end
	for p=tp,1-tp,1-2*tp do
		local zone=zones[p+1]&0xff
		if Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,p,zone) then
			if not check then
				check=true
			end
			table.insert(bs,true)
		else
			table.insert(bs,false)
		end
	end
	if not check or #bs<=0 then return end
	local opt=aux.Option(s_id,tp,1,table.unpack(bs))
	local spsumplayer = (opt==0) and tp or 1-tp
	local spsumzone = (opt==0) and zones[tp+1] or zones[1-tp+1]
	Duel.SpecialSummon(tc,0,tp,spsumplayer,false,false,POS_FACEUP_DEFENSE,spsumzone)
end