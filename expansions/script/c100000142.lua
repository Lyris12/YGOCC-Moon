--Glimmering Stormheart
--Cuoretempesta Baluginante
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.NOT(Card.IsNeutral),1,1,Card.IsNeutral,1)
	c:EnableReviveLimit()
	--[[Once while this card is face-up on the field, during the Main Phase (Quick Effect): 
	You can Fusion Summon 1 Fusion Monster from your Extra Deck (except a monster that mentions exactly 2 monsters as material), 
	using monsters from your hand or field as Fusion Material. You can also use monsters from your Deck as Fusion Material, up to the number of Neutral monsters used for this card's Bigbang Summon.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:OPT()
	e1:SetRelevantTimings()
	e1:SetLabel(0)
	e1:SetCondition(aux.MainPhaseCond())
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetLabelObject(e1)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	--[[If this card is destroyed: Activate this effect; during your opponent's next End Phase, Special Summon this card, then you can return 1 Fusion Monster from your GY to the Extra Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	local cm=getmetatable(c)
	return c:IsType(TYPE_FUSION) and (not cm.FusionMaterialMentions or cm.FusionMaterialMentions~=2) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.fcheck(ct)
	return	function(tp,sg,fc)
				return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ct
			end
end
function s.gcheck(ct)
	return	function(sg)
				return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ct
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetLabel()
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		if ct>0 then
			local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				aux.FCheckAdditional=s.fcheck(ct)
				aux.GCheckAdditional=s.gcheck(ct)
			end
		end
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		aux.FCheckAdditional=nil
		aux.GCheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local exmat=false
	if Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		aux.FCheckAdditional=s.fcheck(ct)
		aux.GCheckAdditional=s.gcheck(ct)
	end
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	aux.FCheckAdditional=nil
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				aux.FCheckAdditional=s.fcheck(ct)
				aux.GCheckAdditional=s.gcheck(ct)
			end
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			aux.FCheckAdditional=nil
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

--E2
function s.matfilter(c)
	return c:IsMonster() and c:IsNeutral()
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(s.matfilter,nil)
	e:GetLabelObject():SetLabel(ct)
end

--E3
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:IsInGY() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_PHASE|PHASE_END|RESET_OPPO_TURN,0,rct,fid)
		local rct=Duel.GetNextPhaseCount(PHASE_END,1-tp)
		local tct = (rct==2) and Duel.GetTurnCount() or 0
		local e1=Effect.CreateEffect(c)
		e1:Desc(1)
		e1:SetCustomCategory(0,CATEGORY_FLAG_DELAYED_RESOLUTION)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid,tct)
		e1:SetLabelObject(c)
		e1:SetCondition(s.spcon1)
		e1:SetOperation(s.spop1)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,rct)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tefilter(c,e,tp)
	return c:IsMonster(TYPE_FUSION) and c:IsAbleToDeck()
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	local fid,tct=e:GetLabel()
	if not c or not c:HasFlagEffectLabel(id,fid) then
		e:Reset()
		return false
	end
	return Duel.GetTurnPlayer()==1-tp and Duel.GetTurnCount()~=tct
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c and not c:IsHasEffect(EFFECT_NECRO_VALLEY) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
	and Duel.IsExists(false,aux.Necro(s.tefilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,STRING_ASK_TOEXTRA) then
		local g=Duel.Select(HINTMSG_TOEXTRA,false,tp,aux.Necro(s.tefilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end