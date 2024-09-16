--[[
Rank-Up-Magic - Admiral's Orders
Alza-Rango-Magico - Ordini dell'Ammiraglio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of the following effects.
	● Target 4 "Dynastygian" monsters you control; their Levels become 10, also, immediately after this effect resolves, Xyz Summon 1 Rank 10 DARK "Number" Xyz Monster from your Extra Deck,
	by using all of those targets as the materials.
	● Target 1 "Number" Xyz Monster you control; Special Summon 1 "Number" Xyz Monster from your Extra Deck with the same number in its name, but a different original name than that target,
	by using that target as the material. (This is treated as an Xyz Summon. Transfer its materials to that monster.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while you control a "Number" Xyz Monster with no materials: You can target 1 of those monsters; return it to the Extra Deck,
	and if you do, add this card to your hand, then draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_TOEXTRA|CATEGORY_TOHAND|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s.LevelChangeGroup=nil
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EFFECT_CHANGE_LEVEL)
		ge1:SetTargetRange(LOCATION_MZONE,0)
		ge1:SetCondition(function() return aux.GetValueType(s.LevelChangeGroup)=="Group" end)
		ge1:SetTarget(function(_e,_c) return s.LevelChangeGroup:IsContains(_c) end)
		ge1:SetValue(10)
		Duel.RegisterEffect(ge1,0)
	end
end
--E1
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:HasLevel() and c:IsCanChangeLevel(10,e,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.gcheck(g,e,tp,mg,c)
	if #g<4 then return true end
	s.LevelChangeGroup=g
	local res=Duel.IsExists(false,s.xyzfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
	s.LevelChangeGroup=nil
	return res, not res
end
function s.xyzfilter1(c,e,tp,mg)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRank(10) and c:IsXyzSummonable(mg,4,4) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.mfilter(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and no
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExists(false,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no,{c:GetOriginalCodeRule()})
end
function s.xyzfilter2(c,e,tp,mc,no,codes)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and aux.GetXyzNumber(c)==no and not c:IsOriginalCodeRule(table.unpack(codes)) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chkc then
		local opt=Duel.GetChainInfo(e:GetChainLink(),CHAININFO_TARGET_PARAM)
		if opt==0 then
			return false
		elseif opt==1 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.mfilter(chkc,e,tp)
		end
	end
	local b1=aux.SelectUnselectGroup(g,e,tp,4,4,s.gcheck,0)
	local b2=Duel.IsExists(true,s.mfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCustomCategory(CATEGORY_LVCHANGE)
		local mg=aux.SelectUnselectGroup(g,e,tp,4,4,s.gcheck,1,tp,HINTMSG_TARGET)
		Duel.SetTargetCard(mg)
		Duel.SetCustomOperationInfo(0,CATEGORY_LVCHANGE,mg,#mg,0,0,{10})
	elseif opt==1 then
		e:SetCustomCategory(0)
		local mg=Duel.Select(HINTMSG_TARGET,true,tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local mg=Duel.GetTargetCards()
		if #mg>0 then
			local c=e:GetHandler()
			for mc in aux.Next(mg) do
				mc:ChangeLevel(10,true,{c,true})
			end
			if #mg==4 and mg:FilterCount(aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),nil)==4 then
				local xyzc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.xyzfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg):GetFirst()
				if xyzc then
					Duel.XyzSummon(tp,xyzc,mg)
				end
			end
		end
	elseif opt==1 then
		local tc=Duel.GetFirstTarget()
		local no=aux.GetXyzNumber(tc)
		if not tc:IsRelateToChain() or not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
			or tc:IsFacedown() or not tc:IsControler(tp) or not tc:IsType(TYPE_XYZ) or not tc:IsSetCard(ARCHE_NUMBER) or tc:IsImmuneToEffect(e) or not no then return end
		local xyzc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,no,{tc:GetOriginalCodeRule()}):GetFirst()
		if xyzc then
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.Overlay(xyzc,mg)
			end
			xyzc:SetMaterial(Group.FromCards(tc))
			Duel.Overlay(xyzc,Group.FromCards(tc))
			if Duel.SpecialSummon(xyzc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				xyzc:CompleteProcedure()
			end
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:GetOverlayCount()==0
end
function s.thfilter(c)
	return s.cfilter(c) and c:IsAbleToExtra()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand() and Duel.IsExists(true,s.thfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOEXTRA)
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
	aux.DrawInfo(tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.ShuffleIntoDeck(tc,nil,LOCATION_EXTRA)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.SearchAndCheck(c) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end