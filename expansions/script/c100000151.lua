--[[
Bond of Harmonic Sisters
Legame delle Sorelle Armoniche
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Apply the following effects, in sequence, based on the type(s) of monsters you control.
	● Bigbang: Add 1 "Bigbang" card from your Deck or GY to your hand, then destroy 1 card in your hand.
	● Link: Special Summon 1 monster from your hand or GY to a zone your Link Monster points to, then send 1 monster a Link Monster points to to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If a monster(s) is Special Summoned from your opponent's Extra Deck while you control no monsters:
	You can banish this card from your GY; Fusion Summon 1 "Sisters of Harmony" from your Extra Deck by banishing Fusion Materials mentioned on it from your Extra Deck or GY.]]
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORIES_FUSION_SUMMON|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT(EFFECT_COUNT_CODE_DUEL)
	e2:SetLabelObject(GYChk)
	e2:SetFunctions(s.fuscon,aux.bfgcost,s.fustg,s.fusop)
	c:RegisterEffect(e2)
end
--E1
function s.thfilter(c)
	return c:IsSetCard(ARCHE_BIGBANG) and c:IsAbleToHand()
end
function s.lkfilter(lc,e,tp,c)
	if not lc:IsFaceup() or not lc:IsType(TYPE_LINK) then return false end
	for p=0,1 do
		if Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,lc:GetLinkedZone(p)&0xff)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p) then
			return true
		end
	end
	return false
end
function s.spfilter(c,e,tp)
	return Duel.IsExists(false,s.lkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
end
function s.tgfilter(c)
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.pointerfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function s.pointerfilter(lc,c)
	if not lc:IsFaceup() or not lc:IsType(TYPE_LINK) then return false end
	return c:IsInLinkedZone(lc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local b1=g:IsExists(Card.IsType,1,nil,TYPE_BIGBANG) and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b2=g:IsExists(Card.IsType,1,nil,TYPE_LINK) and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,zone)
	if chk==0 then return b1 or b2 end
	local f1 = b1 and Duel.SetOperationInfo or Duel.SetPossibleOperationInfo
	local f2 = b2 and Duel.SetOperationInfo or Duel.SetPossibleOperationInfo
	f1(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	f1(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	f2(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	f2(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local break_chk=false
	if g:IsExists(Card.IsType,1,nil,TYPE_BIGBANG) and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #tg>0 and Duel.SearchAndCheck(tg,tp) then
			break_chk=true
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
			if #dg>0 then
				Duel.ShuffleHand(tp)
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_LINK) and Duel.IsExists(false,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) then
		if break_chk then Duel.BreakEffect() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #sg>0 then
			local sc=sg:GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local lg=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,sc)
			if #lg>0 then
				local lc=lg:GetFirst()
				local avail_zone=0
				for p=0,1 do
					local zone=lc:GetLinkedZone(p)&0xff
					local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
					local flag=(~flag_tmp)&0x7f
					if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone) then
						avail_zone=avail_zone|(flag<<(p==tp and 0 or 16))
					end
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
				local sel_zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x00ff00ff&(~avail_zone))
				local sump=0
				if sel_zone&0xff>0 then
					sump=tp
				else
					sump=1-tp
					sel_zone=sel_zone>>16
				end
				if Duel.SpecialSummon(sc,0,tp,sump,false,false,POS_FACEUP,sel_zone)>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
					if #tg>0 then
						Duel.HintSelection(tg)
						Duel.BreakEffect()
						Duel.SendtoGrave(tg,REASON_EFFECT)
					end
				end
			end
		end
	end
end

--E2
function s.cfilter(c,tp,se)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:GetPreviousControler()==1-tp and (se==nil or c:GetReasonEffect()~=se)
end
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.filter1(c,e)
	return c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	local mg=m:Clone()
	mg:RemoveCard(c)
	return c:IsType(TYPE_FUSION) and c:IsCode(CARD_SISTERS_OF_HARMONY) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc=nil
		if e:IsCostChecked() then exc=c end
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,exc,e)
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end