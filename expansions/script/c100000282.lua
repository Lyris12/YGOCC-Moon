--[[
Augury of Prophecy
Auspicio della Profezia
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is in your hand or Monster Zone: You can target 1 banished "Spellbook" card; Special Summon it as a Normal Monster (EARTH/Spellcaster/Level 5/ATK 0/DEF 0),
	then you can make all Spellcaster monsters you currently control become a Level between 4 and 7.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[An Xyz Monster whose original Type is Spellcaster and that has this card as material gains these effects.
	● During your turn, your opponent cannot activate cards or effects in response to the activation of this card's effects.
	● Once per turn, when your opponent activates a card or effect (Quick Effect): You can target 1 banished "Spellbook" card; attach it to this "Prophecy" card as material,
	and if you do, negate that activation.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.xyzcon)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O|EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL|EFFECT_FLAG_CARD_TARGET)
	e3:OPT()
	e3:SetFunctions(s.discon,nil,s.distg,s.disop)
	c:RegisterEffect(e3)
end

--E1
function s.spfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsSetCard(ARCHE_SPELLBOOK)) then return false end
	local spcheck=not c:IsMonster()
	if not c:IsCanBeSpecialSummoned(e,0,tp,spcheck,false) then return false end
	local setcode=Duel.ReadCard(c,CARDDATA_SETCODE)
	local typ=c:IsType(TYPE_TUNER) and TYPE_NORMAL|TYPE_MONSTER|TYPE_TUNER or TYPE_NORMAL|TYPE_MONSTER
	return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),setcode,typ,0,0,5,RACE_SPELLCASTER,ATTRIBUTE_EARTH)
end
function s.lvfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)) then return false end
	for i=4,7 do
		if c:IsCanChangeLevel(i,e,tp,REASON_EFFECT) then
			return true
		end
	end
	return false
end
function s.lvcheck(g,e)
	return	function(lv,tp)
				return g:IsExists(Card.IsCanChangeLevel,1,nil,lv,e,tp,REASON_EFFECT)
			end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(true,s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local spcheck=not tc:IsMonster()
		if not tc:IsCanBeSpecialSummoned(e,0,tp,spcheck,false) then return end
		local setcode=Duel.ReadCard(tc,CARDDATA_SETCODE)
		local typ=tc:IsType(TYPE_TUNER) and TYPE_NORMAL|TYPE_MONSTER|TYPE_TUNER or TYPE_NORMAL|TYPE_MONSTER
		if Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),setcode,typ,0,0,5,RACE_SPELLCASTER,ATTRIBUTE_EARTH) then
			local c=e:GetHandler()
			if tc:IsMonster() then
				local ogtype=tc:GetOriginalType()
				local eid=e:GetFieldID()
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_TOFIELD,0,0,eid)
				tc:SetCardData(CARDDATA_TYPE,typ)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
				e2:SetCode(EFFECT_CHANGE_RACE)
				e2:SetValue(RACE_SPELLCASTER)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
				tc:RegisterEffect(e2,true)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e3:SetValue(ATTRIBUTE_EARTH)
				tc:RegisterEffect(e3,true)
				local e4=e2:Clone()
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(5)
				tc:RegisterEffect(e4,true)
				local e5=e2:Clone()
				e5:SetCode(EFFECT_SET_BASE_ATTACK)
				e5:SetValue(0)
				tc:RegisterEffect(e5,true)
				local e6=e2:Clone()
				e6:SetCode(EFFECT_SET_BASE_DEFENSE)
				e6:SetValue(0)
				tc:RegisterEffect(e6,true)
				local e7=Effect.CreateEffect(c)
				e7:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e7:SetCode(EVENT_ADJUST)
				e7:SetLabel(eid,ogtype)
				e7:SetLabelObject(tc)
				e7:SetOperation(s.resetop)
				Duel.RegisterEffect(e7,tp)
			else
				tc:AddMonsterAttribute(TYPE_NORMAL|TYPE_MONSTER,ATTRIBUTE_EARTH,RACE_SPELLCASTER,5,0,0)
			end
			if Duel.SpecialSummon(tc,0,tp,tp,spcheck,false,POS_FACEUP)>0 then
				local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
				if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_CHANGE_LEVEL) then
					local lv=Duel.AnnounceNumberMinMax(tp,4,7,s.lvcheck(g,e))
					Duel.BreakEffect()
					for tc in aux.Next(g) do
						tc:ChangeLevel(lv,true,{c,true})
					end
				end
			else
				tc:ResetFlagEffect(id)
			end
		end
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local eid,ogtype=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc:HasFlagEffectLabel(id,eid) then
		tc:SetCardData(CARDDATA_TYPE,ogtype)
		e:Reset()
	end
end

--E2
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:GetOriginalRace()&RACE_SPELLCASTER>0
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc and rc==e:GetHandler() then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

--E3
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:GetOriginalRace()&RACE_SPELLCASTER>0 and rp~=tp and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.atfilter(c,xyzc,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_SPELLBOOK) and c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.atfilter(chkc,c,e,tp) end
	if chk==0 then return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_PROPHECY) and Duel.IsExists(true,s.atfilter,tp,LOCATION_REMOVED,0,1,nil,c,e,tp) end
	local g=Duel.Select(HINTMSG_ATTACH,true,tp,s.atfilter,tp,LOCATION_REMOVED,0,1,1,nil,c,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsType(TYPE_XYZ) or not c:IsFaceup() or not c:IsSetCard(ARCHE_PROPHECY) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsCanBeAttachedTo(c,e,tp,REASON_EFFECT) and Duel.Attach(tc,c,false,e,tp,REASON_EFFECT) then
		Duel.NegateActivation(ev)
	end
end